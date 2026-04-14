local keymaps = require('dotvim.utils').keymaps

keymaps({
  -- drop to noop
  { 'n', 'H', '<Nop>' },
  { 'n', 'M', '<Nop>' },
  { 'n', 'L', '<Nop>' },

  -- splits
  { 'n', 's', '<Nop>' },

  { 'n', 'sj', '<C-w>j' },
  { 'n', 'sk', '<C-w>k' },
  { 'n', 'sl', '<C-w>l' },
  { 'n', 'sh', '<C-w>h' },

  { 'n', 'sJ', '<C-w>J' },
  { 'n', 'sK', '<C-w>K' },
  { 'n', 'sL', '<C-w>L' },
  { 'n', 'sH', '<C-w>H' },

  { 'n', 's=', '<C-w>=' },

  { 'n', 'sn', '<Esc>:<C-u>bn<CR>', { silent = true } },
  { 'n', 'sp', '<Esc>:<C-u>bp<CR>', { silent = true } },

  { 'n', 'ss', '<Esc>:<C-u>sp<CR>', { silent = true } },
  { 'n', 'sv', '<Esc>:<C-u>vs<CR>', { silent = true } },

  -- tabs
  { 'n', '<C-n>', 'gt' },
  { 'n', '<C-p>', 'gT' },

  -- + register
  { 'n', '<Space>y', '"+yy' },
  { 'v', '<Space>y', '"+yy' },
  { 'n', '<Space>p', '"+p' },
  { 'v', '<Space>p', '"+p' },

  -- escape terminal mode
  { 't', '<ESC>', '<C-\\><C-n><Plug>(esc)' },
  { 'n', '<Plug>(esc)<ESC>', 'i<ESC>' },

  -- re-syntax
  { 'n', '<C-s>', '<Esc>:syntax sync fromstart<CR>', { silent = true } },

  -- expand path on command-line
  { 'c', '<C-x>', [[<C-r>=expand('%:h')<CR>]] },
  { 'c', '<C-c>', [[<C-r>=expand('%:p')<CR>]] },
})

local bufremove = require('dotvim.plugins.mini').bufremove

keymaps({
  { 'n', 'sa', bufremove.delete }
})
