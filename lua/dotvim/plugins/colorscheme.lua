vim.pack.add({
  { src = 'https://github.com/EdenEast/nightfox.nvim' },
})

require('nightfox').setup({
  options = {
    styles = {
      conditionals = 'italic',
      keywords = 'italic',
    },
  },
})

vim.cmd.colorscheme('nordfox')

local hl_set = require('dotvim.utils').hl_set

hl_set({
  Normal = { bg = 'NONE' },
  NormalNC = { bg = 'NONE' },
})

local nordfox = require('nightfox.palette.nordfox')

return {
  palette = nordfox.palette
}
