vim.pack.add({
  { src = 'https://github.com/kevinhwang91/promise-async' },
  { src = 'https://github.com/kevinhwang91/nvim-ufo' },
})

vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:'

local ufo = require('ufo')

ufo.setup({
  provider_selector = function()
    return { 'treesitter', 'indent' }
  end
})

local keymaps = require('dotvim.utils').keymaps

keymaps({
  { 'n', 'zR', ufo.openAllFolds },
  { 'n', 'zM', ufo.closeAllFolds },
})

