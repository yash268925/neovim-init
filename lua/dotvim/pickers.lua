local mini = require('dotvim.plugins.mini')
local pick, extra = mini.pick, mini.extra
local keymaps = require('dotvim.utils').keymaps

local function show_buffer_picker()
  -- builtin の items を生成する部分だけコピー
  local local_opts = { include_current = false, include_unlisted = false }

  local buffers_output = vim.api.nvim_exec('buffers' .. (local_opts.include_unlisted and '!' or ''), true)
  local cur_buf_id, include_current = vim.api.nvim_get_current_buf(), local_opts.include_current ~= false
  local items = {}

  for _, l in ipairs(vim.split(buffers_output, '\n')) do
    local buf_str, name = l:match('^%s*%d+'), l:match('"(.*)"')
    local buf_id = tonumber(buf_str)

    if buf_id then
      local text = name

      -- ここで modified を見る
      local modified = vim.api.nvim_get_option_value('modified', { buf = buf_id })
      if modified then
        text = '+ ' .. text
      end

      if buf_id ~= cur_buf_id or include_current then
        table.insert(items, { text = text, bufnr = buf_id })
      end
    end
  end

  pick.start({
    source = {
      name = 'Buffers',
      items = items,
      show = function(buf_id, items, query) MiniPick.default_show(buf_id, items, query, { show_icons = true }) end
    },
    mappings = {
      wipeout = {
        char = '<C-d>',
        func = function()
          local matches = MiniPick.get_picker_matches()
          -- markedがあればそれを、なければcurrentを対象に
          local targets = matches ~= nil and (#matches.marked > 0 and matches.marked or { matches.current }) or {}

          -- 削除対象のbufnrセットを作る
          local to_delete = {}
          for _, item in ipairs(targets) do
            to_delete[item.bufnr] = true
          end

          -- bdを実行
          for bufnr, _ in pairs(to_delete) do
            vim.api.nvim_buf_delete(bufnr, { force = false })
          end

          -- pickerのitemsを更新（削除済みbufnrを除外）
          local current_items = MiniPick.get_picker_items()
          local new_items = vim.tbl_filter(function(item)
            return not to_delete[item.bufnr]
          end, current_items or {})
          MiniPick.set_picker_items(new_items)
        end,
      },
    },
  })
end

local function show_files_picker()
  pick.builtin.files({ tool = 'fd' })
end

local function show_grep_picker()
  pick.builtin.grep_live({ tool = 'rg' })
end

local function show_references_picker()
  extra.pickers.lsp({ scope = 'references' })
end

local function show_error_picker()
  extra.pickers.diagnostic({ scope = 'all' })
end

keymaps({
  { 'n', ';b', show_buffer_picker },
  { 'n', ';f', show_files_picker },
  { 'n', ';g', show_grep_picker },
  { 'n', ';r', show_references_picker },
  { 'n', ';e', show_error_picker },
})
