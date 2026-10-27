require('nightfox').setup({
  options = {
    transparent = true,
    styles = {
      conditionals = 'italic',
      keywords = 'italic',
    },
  },
})

vim.o.termguicolors = true
vim.o.winblend = 0

vim.cmd.colorscheme('nordfox')
