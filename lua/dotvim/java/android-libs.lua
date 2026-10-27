-- :JdtlsAndroidLibs の本体。Android モジュールの依存 JAR 一覧を Gradle で生成し、
-- そのモジュールの jdtls を作り直す。

local jdtls = require('dotvim.java.jdtls')

local M = {}

local init_script = vim.fs.joinpath(
  vim.fs.dirname(vim.fs.normalize(debug.getinfo(1, 'S').source:sub(2))),
  'android-libs.init.gradle'
)

---@param root_dir string
---@param module_dir string
---@return string
local function relative_dir(root_dir, module_dir)
  return module_dir:sub(#root_dir + 2)
end

---@param root_dir string
---@return string[]
function M.list_modules(root_dir)
  local modules = {}
  for name, type in
    vim.fs.dir(root_dir, {
      depth = 3,
      skip = function(dir)
        local base = vim.fs.basename(dir)
        return base ~= 'build' and not vim.startswith(base, '.')
      end,
    })
  do
    local base = vim.fs.basename(name)
    if type == 'directory' and base ~= 'build' and not vim.startswith(base, '.') then
      local dir = root_dir .. '/' .. name
      local is_gradle_module = vim.fn.filereadable(dir .. '/build.gradle') == 1
        or vim.fn.filereadable(dir .. '/build.gradle.kts') == 1
      if is_gradle_module and vim.fn.filereadable(dir .. '/src/main/AndroidManifest.xml') == 1 then
        table.insert(modules, name)
      end
    end
  end
  table.sort(modules)
  return modules
end

---@param root_dir string
---@param module_dir string
---@return { argv: string[], module_name: string, variant: string }?, string? err
function M.build_cmd(root_dir, module_dir)
  local gradlew = root_dir .. '/gradlew'
  if vim.fn.executable(gradlew) ~= 1 then
    if vim.fn.executable('gradle') ~= 1 then
      return nil, root_dir .. ' に gradlew が無く、PATH にも gradle がありません'
    end
    gradlew = 'gradle'
  end

  local module_name = vim.fn.fnamemodify(module_dir, ':t')
  local variant = jdtls.resolve_android_opts(module_name).variant
  local gradle_path = ':' .. relative_dir(root_dir, module_dir):gsub('/', ':')
  local out_prefix = vim.fn.stdpath('cache') .. '/jdtls-libs/' .. jdtls.project_name(root_dir) .. '-'

  return {
    argv = {
      gradlew,
      '-I',
      init_script,
      '-Pjdtls.variant=' .. variant,
      '-Pjdtls.outPrefix=' .. out_prefix,
      gradle_path .. ':process' .. variant:sub(1, 1):upper() .. variant:sub(2) .. 'Resources',
      gradle_path .. ':jdtlsLibs',
    },
    module_name = module_name,
    variant = variant,
  }
end

-- 新しい jdtls は同じ -data の workspace を使うため、旧プロセスが終了するまで
-- start を待つ。is_stopped() は stop() の直後から true になり、終了の判定に
-- 使えない。クライアントはプロセス終了後に get_client_by_id から消える。
---@param clients vim.lsp.Client[]
---@param on_stopped fun()
local function stop_clients(clients, on_stopped)
  for _, client in ipairs(clients) do
    client:stop()
  end
  local waited = 0
  local function poll()
    local all_stopped = vim.iter(clients):all(function(client)
      return vim.lsp.get_client_by_id(client.id) == nil
    end)
    if all_stopped or waited >= 10000 then
      on_stopped()
      return
    end
    waited = waited + 100
    if waited == 5000 then
      for _, client in ipairs(clients) do
        client:stop(true)
      end
    end
    vim.defer_fn(poll, 100)
  end
  poll()
end

-- キャッシュが無い間はルート単位の Gradle インポートで起動していることがあるため、
-- モジュール配下のバッファに付いたクライアントを根本によらずまとめて作り直す。
-- JdtRestart は全 jdtls クライアントを同じ config で再起動するだけなので使わない。
---@param module_dir string
local function restart_jdtls(module_dir)
  local clients = {}
  local client_ids = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.startswith(vim.api.nvim_buf_get_name(buf), module_dir .. '/') then
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, name = 'jdtls' })) do
        if not client_ids[client.id] then
          client_ids[client.id] = true
          table.insert(clients, client)
        end
      end
    end
  end
  if #clients == 0 then
    return
  end

  local bufs = {}
  for _, client in ipairs(clients) do
    for buf in pairs(client.attached_buffers) do
      bufs[buf] = true
    end
  end

  stop_clients(clients, function()
    for buf in pairs(bufs) do
      if vim.api.nvim_buf_is_loaded(buf) then
        jdtls.start(buf)
      end
    end
  end)
end

---@param root_dir string
---@param module_dir string
local function refresh(root_dir, module_dir)
  local project_name = jdtls.project_name(root_dir)
  local module_name = vim.fn.fnamemodify(module_dir, ':t')
  local libs_cache = vim.fn.stdpath('cache') .. '/jdtls-libs/' .. project_name .. '-' .. module_name .. '.txt'
  -- Gradle のプロジェクト名とディレクトリ名が違うと、別のファイル名で出力される。
  if vim.fn.filereadable(libs_cache) == 0 then
    vim.notify(
      'JdtlsAndroidLibs: 出力が見つかりません: ' .. libs_cache .. ' (Gradle のプロジェクト名がディレクトリ名と異なる可能性があります)',
      vim.log.levels.WARN
    )
    return
  end
  jdtls.write_eclipse_project(
    module_dir,
    project_name,
    module_name,
    jdtls.resolve_android_opts(module_name),
    libs_cache
  )
  restart_jdtls(module_dir)
end

---@param output string
---@return string[]
local function tail(output, n)
  local lines = vim.split(vim.trim(output), '\n')
  return vim.list_slice(lines, math.max(1, #lines - n + 1))
end

---@param root_dir string
---@param module_dirs string[]
local function run(root_dir, module_dirs)
  local function step(i)
    local module_dir = module_dirs[i]
    if not module_dir then
      return
    end

    local cmd, err = M.build_cmd(root_dir, module_dir)
    if not cmd then
      vim.notify('JdtlsAndroidLibs: ' .. err, vim.log.levels.ERROR)
      return
    end

    vim.notify(
      ('JdtlsAndroidLibs: %s (variant: %s) の依存一覧を生成します'):format(relative_dir(root_dir, module_dir), cmd.variant),
      vim.log.levels.INFO
    )
    vim.system(cmd.argv, { cwd = root_dir, text = true }, function(result)
      vim.schedule(function()
        local output = (result.stdout or '') .. '\n' .. (result.stderr or '')
        if result.code ~= 0 then
          vim.notify(
            ('JdtlsAndroidLibs: gradle が失敗しました (終了コード %d)\n%s'):format(
              result.code,
              table.concat(tail(output, 20), '\n')
            ),
            vim.log.levels.ERROR
          )
          return
        end
        local summary = output:match('jdtlsLibs: [^\n]*') or 'jdtlsLibs: 完了'
        vim.notify('JdtlsAndroidLibs: ' .. summary, vim.log.levels.INFO)
        refresh(root_dir, module_dir)
        step(i + 1)
      end)
    end)
  end
  step(1)
end

---@param args string[]
function M.command(args)
  local bufname = vim.api.nvim_buf_get_name(0)
  local root_dir = jdtls.find_root(bufname)

  local module_dirs = {}
  if #args == 0 then
    local module_dir = root_dir and jdtls.find_android_module_dir(bufname, root_dir)
    if not module_dir then
      vim.notify(
        'JdtlsAndroidLibs: Android モジュール内のバッファで実行するか、モジュールを引数で指定してください',
        vim.log.levels.WARN
      )
      return
    end
    table.insert(module_dirs, module_dir)
  else
    if not root_dir then
      vim.notify('JdtlsAndroidLibs: プロジェクトルートが見つかりません', vim.log.levels.WARN)
      return
    end
    for _, arg in ipairs(args) do
      local module_dir = root_dir .. '/' .. arg:gsub('/+$', '')
      if vim.fn.isdirectory(module_dir) == 0 then
        vim.notify('JdtlsAndroidLibs: ディレクトリがありません: ' .. module_dir, vim.log.levels.ERROR)
        return
      end
      table.insert(module_dirs, module_dir)
    end
  end

  run(root_dir, module_dirs)
end

---@param arglead string
---@return string[]
function M.complete(arglead)
  local root_dir = jdtls.find_root(vim.api.nvim_buf_get_name(0))
  if not root_dir then
    return {}
  end
  return vim.tbl_filter(function(name)
    return vim.startswith(name, arglead)
  end, M.list_modules(root_dir))
end

return M
