vim.pack.add({
  require('dotvim._lib.specs').nightfox,
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
vim.o.winblend = 0

vim.cmd.colorscheme('nordfox')

return {
  palette = require('dotvim._lib.palette')
}
