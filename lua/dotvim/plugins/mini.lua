vim.pack.add({
  { src = 'https://github.com/echasnovski/mini.icons' },
  { src = 'https://github.com/echasnovski/mini.bufremove' },
  { src = 'https://github.com/echasnovski/mini.files' },
  { src = 'https://github.com/echasnovski/mini.indentscope' },
  { src = 'https://github.com/echasnovski/mini.pick' },
  { src = 'https://github.com/echasnovski/mini.extra' },
  { src = 'https://github.com/echasnovski/mini.diff' },
})

local icons = require('mini.icons')
icons.setup()

local bufremove = require('mini.bufremove')
bufremove.setup()

local files = require('mini.files')
files.setup({
  content = {
    sort = function(entries)
      local function rank(name)
        -- 1: 先頭大文字 + 小文字を含む (Capitalized系)
        -- 2: 全部大文字 (XXX系)
        -- 3: それ以外 (not-capitalized / xxx など)
        if name:match('^%u') then
          if name:match('%l') then return 1 end
          return 2
        end
        return 3
      end

      table.sort(entries, function(a, b)
        local ad = a.fs_type == 'directory'
        local bd = b.fs_type == 'directory'
        if ad ~= bd then return ad end

        local ar, br = rank(a.name), rank(b.name)
        if ar ~= br then return ar < br end

        local al, bl = a.name:lower(), b.name:lower()
        if al ~= bl then return al < bl end
        return a.name < b.name
      end)

      return entries
    end,
  },
})

local indentscope = require('mini.indentscope')
indentscope.setup({
  draw = {
    delay = 30,
    animation = function() return 8 end,
  },
  symbol = '┆',
})

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(args)
    vim.b[args.buf].miniindentscope_disable = true
  end,
})

local pick = require('mini.pick')
pick.setup({
  options = {
    content_from_bottom = true,
  },
})

local extra = require('mini.extra')
extra.setup()

local diff = require('mini.diff')
diff.setup({
  view = {
    style = 'sign',
  },
})

return {
  icons = icons,
  bufremove = bufremove,
  pick = pick,
  extra = extra,
}
