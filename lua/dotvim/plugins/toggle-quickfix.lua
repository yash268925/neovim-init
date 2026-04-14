vim.pack.add({
  { src = 'https://github.com/drmingdrmer/vim-toggle-quickfix' },
})

local keymaps = require('dotvim.utils').keymaps

keymaps({
  { 'n', '<C-q><C-l>', '<Plug>window:quickfix:loop' },
})
