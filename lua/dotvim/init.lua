local M = {}

local order = {
  'base',
  'ui',
  'picker',
  'lsp',
  'completion',
  'quickfix',
  'skk',
  'git',
  'aibo',
  'java',
  'term-edit',
  'color-picker',
  'hl-marker',
  'md-render',
  'ja-doc',
}

local known = {}
for _, name in ipairs(order) do
  known[name] = true
end

---@param features table<string, table | boolean>
function M.setup(features)
  features = features or {}

  -- 誤字ひとつで設定全体を止めないよう、未知の機能名は知らせて飛ばす
  for name in pairs(features) do
    if not known[name] then
      vim.notify(('dotvim: unknown feature %q'):format(name), vim.log.levels.ERROR)
    end
  end

  local selected = {}
  local specs = {}
  for _, name in ipairs(order) do
    local opts = features[name]
    if opts then
      local feature = require('dotvim.' .. name)
      table.insert(selected, { feature = feature, opts = opts == true and {} or opts })
      vim.list_extend(specs, feature.specs)
    end
  end

  -- lockfile が無いマシンでは vim.pack.add の呼び出しごとにインストール確認が出るため、1 回にまとめる。
  -- 各機能の setup も vim.pack.add を呼ぶが、追加済みのプラグインは無視される。
  if #specs > 0 then
    vim.pack.add(specs)
  end

  for _, entry in ipairs(selected) do
    entry.feature.setup(entry.opts)
  end
end

return M
