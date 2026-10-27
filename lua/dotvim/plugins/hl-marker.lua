vim.pack.add({
  { src = 'https://github.com/t9md/vim-quickhl' }
})

local keymaps = require('dotvim._lib.utils').keymaps

keymaps({
  { { 'n', 'x' }, '<Space>m', '<Plug>(quickhl-manual-this)' },
  { { 'n', 'x' }, '<Space>M', '<Plug>(quickhl-manual-reset)' },
  { 'n',          '<Space>j', '<Plug>(quickhl-cword-toggle)' },
})
