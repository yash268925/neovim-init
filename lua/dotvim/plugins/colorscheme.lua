vim.pack.add({
  { src = 'https://github.com/EdenEast/nightfox.nvim' },
})

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
vim.o.winblend = 4

vim.cmd.colorscheme('nordfox')

return {
  palette = require('nightfox.palette').load('nordfox')
}
