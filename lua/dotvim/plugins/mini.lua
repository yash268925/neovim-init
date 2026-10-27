vim.pack.add({
  { src = 'https://github.com/echasnovski/mini.diff' },
})

local diff = require('mini.diff')
diff.setup({
  view = {
    style = 'sign',
  },
})
