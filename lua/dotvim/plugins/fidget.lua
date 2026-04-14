vim.pack.add({
  { src = 'https://github.com/j-hui/fidget.nvim' }
})

local fidget = require('fidget')

fidget.setup({
  notification = {
    override_vim_notify = true,
    window = {
      winblend = 40,
      max_width = 100,
      y_padding = 1,
    },
  },
})
