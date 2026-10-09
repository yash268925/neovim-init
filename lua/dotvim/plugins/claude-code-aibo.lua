vim.pack.add({
  { src = 'https://github.com/lambdalisue/nvim-aibo' }
})

local aibo = require('aibo')

aibo.setup({
  termcode_mode = 'csi-n',
  prompt = {
    on_attach = function(bufnr)
      local opts = { buffer = bufnr, nowait = true, silent = true }
      -- Add custom mappings using <Plug>(aibo-send) pattern
      -- vim.keymap.set({ 'n', 'i' }, '<C-j>', '<Plug>(aibo-send)<Down>', opts)
      -- vim.keymap.set({ 'n', 'i' }, '<C-k>', '<Plug>(aibo-send)<Up>', opts)
    end,
  },
})

-- <Plug>(aibo-send)<Key> 形式のマッピングでも、送るキーが既に typeahead に
-- 積まれているのに毎回 "Oneshot (press any key):" を echo してしまう。
-- プラグインに抑止の設定がないため、キー待ちが不要なときだけ prompt を外す。
do
  local keycode = require('aibo.internal.keycode')
  local get_single_keycode = keycode.get_single_keycode
  keycode.get_single_keycode = function(options)
    if options and options.prompt and vim.fn.getchar(1) ~= 0 then
      options = vim.deepcopy(options)
      options.prompt = nil
    end
    return get_single_keycode(options)
  end
end

local function warn(msg)
  vim.notify('[claude-scratchpad] ' .. msg, vim.log.levels.WARN)
end

-- Claude Code の内部仕様 (sessions/<pid>.json と scratchpad の配置) に依存して
-- いるため、claude 本体の更新で壊れうる。sessionId は /clear で変わるので
-- キャッシュせず、呼ぶたびに解決する。
local function resolve_scratchpad(bufnr)
  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then
    return nil, 'terminal job not found'
  end
  local ok, pid = pcall(vim.fn.jobpid, job_id)
  if not ok then
    return nil, 'claude process has exited'
  end

  local config_dir = vim.env.CLAUDE_CONFIG_DIR or vim.fs.joinpath(vim.env.HOME, '.claude')
  local session_file = vim.fs.joinpath(config_dir, 'sessions', pid .. '.json')
  local read_ok, lines = pcall(vim.fn.readfile, session_file)
  if not read_ok then
    return nil, 'session file not found: ' .. session_file
  end
  local decode_ok, session = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not decode_ok or type(session) ~= 'table' or type(session.sessionId) ~= 'string' then
    return nil, 'sessionId not found in ' .. session_file
  end

  -- 中間のディレクトリは cwd をエンコードした名前だが、エンコード規則を
  -- 再現せず sessionId だけで探す。
  local tmpdir = vim.env.CLAUDE_CODE_TMPDIR or '/tmp'
  local pattern = vim.fs.joinpath(tmpdir, 'claude-' .. vim.uv.getuid(), '*', session.sessionId, 'scratchpad')
  local dirs = vim.tbl_filter(function(dir)
    return vim.fn.isdirectory(dir) == 1
  end, vim.fn.glob(pattern, false, true))
  if #dirs == 0 then
    return nil, 'scratchpad not found for session ' .. session.sessionId
  end
  return dirs[1]
end

local function is_edit_target(win)
  if vim.api.nvim_win_get_config(win).relative ~= '' then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype ~= '' then
    return false
  end
  local ft = vim.bo[buf].filetype
  return ft ~= 'deck' and not ft:match('^aibo%-')
end

-- 組み込みの open は deck の WinEnter 履歴から開き先を選ぶため、履歴に通常
-- ウィンドウが無いとコンソール自身で開いてしまう。ピッカー起動時のコンソールを
-- 基準に、同じタブの通常ウィンドウを選び直す。
local function find_edit_window(origin_win, alt_win)
  if alt_win and vim.api.nvim_win_is_valid(alt_win) and is_edit_target(alt_win) then
    return alt_win
  end
  local tab = vim.api.nvim_win_get_tabpage(origin_win)
  return vim.iter(vim.api.nvim_tabpage_list_wins(tab)):find(is_edit_target)
end

local function open_in_edit_window(origin_win, alt_win, filename)
  local win = find_edit_window(origin_win, alt_win)
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.api.nvim_set_current_win(origin_win)
    vim.cmd('topleft vnew')
    -- 新しいウィンドウはコンソールの winfixwidth を引き継ぐため、外さないと
    -- 以降の分割でこちらの幅も固定されてしまう。
    vim.wo.winfixwidth = false
  end
  local target = vim.fn.bufnr(filename)
  if target ~= -1 then
    vim.cmd.buffer(target)
  else
    vim.cmd.edit(vim.fn.fnameescape(filename))
  end
end

local function open_scratchpad_picker(bufnr)
  local root, err = resolve_scratchpad(bufnr)
  if not root then
    warn(err)
    return
  end

  local origin_win = vim.api.nvim_get_current_win()
  local alt_nr = vim.fn.winnr('#')
  local alt_win = alt_nr > 0 and vim.fn.win_getid(alt_nr) or nil

  local deck = require('deck')
  deck.start({
    name = 'claude-scratchpad',
    execute = function(ctx)
      local files = {}
      for name, ftype in vim.fs.dir(root, { depth = 10 }) do
        if ftype == 'file' then
          local filename = vim.fs.joinpath(root, name)
          local stat = vim.uv.fs_stat(filename)
          table.insert(files, { name = name, filename = filename, mtime = stat and stat.mtime.sec or 0 })
        end
      end
      table.sort(files, function(a, b)
        return a.mtime > b.mtime
      end)
      for _, file in ipairs(files) do
        ctx.item({
          display_text = {
            { file.name .. ' ' },
            { os.date('%Y-%m-%d %H:%M', file.mtime), 'Comment' },
          },
          data = { filename = file.filename },
        })
      end
      ctx.done()
    end,
    actions = {
      {
        name = 'default',
        resolve = function(ctx)
          return #ctx.get_action_items() > 0
        end,
        execute = function(ctx)
          local items = ctx.get_action_items()
          ctx.hide()
          open_in_edit_window(origin_win, alt_win, items[#items].data.filename)
        end,
      },
    },
  })
end

-- Runs after nvim-aibo's own ftplugin/aibo-*.lua (built-in ftplugin loading
-- is wired up before user config, so a later `FileType` autocmd for the same
-- pattern always fires after it -- the standard ftplugin-overrule idiom).
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'aibo-*',
  callback = function(ev)
    vim.wo.winfixwidth = true

    local bufnr = ev.buf
    local bufname = vim.api.nvim_buf_get_name(bufnr)

    if bufname:match('^aiboconsole://') then
      -- Claude Code の TUI 自身にスクロールさせたいが、コンソール側の
      -- ftplugin は <PageUp>/<PageDown> を割り当てないため、<C-g>i の
      -- Direct Mode に入らないと端末へ届かない。codex 用 ftplugin と同じ
      -- <Plug>(aibo-send) 転送をここで補う。
      local opts = { buffer = bufnr, nowait = true, silent = true }
      vim.keymap.set({ 'n', 'i' }, '<PageUp>', '<Plug>(aibo-send)<PageUp>', opts)
      vim.keymap.set({ 'n', 'i' }, '<PageDown>', '<Plug>(aibo-send)<PageDown>', opts)

      if bufname:match('^aiboconsole://claude/') then
        vim.keymap.set('n', ';s', function()
          open_scratchpad_picker(bufnr)
        end, { buffer = bufnr, silent = true, desc = 'Claude scratchpad files' })
      end
      return
    end

    if not bufname:match('^aiboprompt://') then
      return
    end

    -- Hand "/" and "@" over to nvim-ix: drop nvim-aibo's own triggers
    -- (<C-x><C-o> / vim.fn.complete()) so the characters just self-insert
    -- and nvim-ix's normal TextChangedI auto-trigger picks them up via the
    -- aibo-slash / aibo-file sources registered in dotvim.plugins.completion.
    pcall(vim.keymap.del, 'i', '/', { buffer = bufnr })
    pcall(vim.keymap.del, 'i', '@', { buffer = bufnr })

    -- nvim-aibo's own <C-n>/<C-p> only special-case the native pum
    -- (pumvisible()), so with the triggers above removed they never see
    -- nvim-ix's floating menu and always fall through to history
    -- navigation. Prefer selecting in nvim-ix's menu when it is visible;
    -- otherwise keep aibo's prompt-history prev/next.
    local ix = require('ix')

    local function history(direction)
      local plug = direction == 'next' and '<Plug>(aibo-history-next)' or '<Plug>(aibo-history-prev)'
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(plug, true, false, true), 'm', false)
    end

    vim.keymap.set('i', '<C-n>', function()
      if ix.get_completion_service():is_menu_visible() then
        (ix.action.completion.select_next())()
      else
        history('next')
      end
    end, { buffer = bufnr, silent = true })

    vim.keymap.set('i', '<C-p>', function()
      if ix.get_completion_service():is_menu_visible() then
        (ix.action.completion.select_prev())()
      else
        history('prev')
      end
    end, { buffer = bufnr, silent = true })
  end,
})

-- nvim-aibo の `-toggle` は cmd+args が完全一致する既存インスタンスしか
-- 検出できないため、引数を変えて :Claude を呼ぶと別インスタンス扱いになり
-- トグルされない。ここでは直近に開いたバッファを自前で覚えておき、それが
-- window内に見えていれば閉じるだけにすることで、引数によらないトグルにする。
local claude_state = { bufnr = nil }

-- デフォルトで起動するエージェントは ~/.claude/settings.json の `agent` で
-- 設定する (claude 本体が面倒を見てくれるので、ここでは --agent を付けない)。

local function is_claude_win_visible()
  return claude_state.bufnr ~= nil
    and vim.api.nvim_buf_is_valid(claude_state.bufnr)
    and #vim.fn.win_findbuf(claude_state.bufnr) > 0
end

local function toggle_claude(args)
  if is_claude_win_visible() then
    for _, winid in ipairs(vim.fn.win_findbuf(claude_state.bufnr)) do
      vim.api.nvim_win_close(winid, false)
    end
    return
  end

  local claude_args = vim.trim(args or '')

  local width = math.floor(vim.o.columns * 1 / 3)
  local cmd = string.format('Aibo -toggle -opener="botright %dvsplit" claude', width)
  if claude_args ~= '' then
    cmd = cmd .. ' ' .. claude_args
  end
  vim.cmd(cmd)

  -- nvim-aibo の内部APIから、いま開いた(または再表示した)コンソールの
  -- バッファ番号を取得して覚えておく。将来の nvim-aibo 更新で
  -- internal モジュールの形が変わると壊れうる点は留意。
  local ok, console = pcall(require, 'aibo.internal.console_window')
  if ok then
    local parsed_args = claude_args ~= '' and vim.split(claude_args, '%s+') or {}
    local info = console.find_info_globally({ cmd = 'claude', args = parsed_args })
    if info then
      claude_state.bufnr = info.bufnr
    end
  end
end

local keymaps = require('dotvim.utils').keymaps

keymaps({
  { 'n', ';c', function() toggle_claude() end },
})

vim.api.nvim_create_user_command('Claude', function(opts)
  toggle_claude(opts.args)
end, { nargs = '*' })
