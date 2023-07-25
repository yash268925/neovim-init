vim.opt.title = false
vim.opt.backup = false
vim.opt.clipboard:append {'unnamedplus'}
vim.opt.cmdheight = 0
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.writebackup = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 4
vim.opt.winblend = 0
vim.opt.pumblend = 5
vim.opt.wildoptions = 'pum'
vim.opt.modeline = true
vim.opt.laststatus = 2
vim.opt.list = true
vim.opt.listchars = { eol = '$', tab = '>-', space = '.' }
vim.opt.equalalways = false
vim.opt.showtabline = 2


vim.keymap.set('n', 's', '<Nop>')
vim.keymap.set('n', 'sj', '<C-w>j')
vim.keymap.set('n', 'sk', '<C-w>k')
vim.keymap.set('n', 'sl', '<C-w>l')
vim.keymap.set('n', 'sh', '<C-w>h')
vim.keymap.set('n', 'sJ', '<C-w>J')
vim.keymap.set('n', 'sK', '<C-w>K')
vim.keymap.set('n', 'sL', '<C-w>L')
vim.keymap.set('n', 'sH', '<C-w>H')
vim.keymap.set('n', 'sN', 'gt')
vim.keymap.set('n', 'sP', 'gT')
vim.keymap.set('n', 'sr', '<C-w>r')
vim.keymap.set('n', 's=', '<C-w>=')
vim.keymap.set('n', 'sw', '<C-w>w')
vim.keymap.set('n', 'sn', '<Esc>:<C-u>bn<CR>', { silent = true })
vim.keymap.set('n', 'sp', '<Esc>:<C-u>bp<CR>', { silent = true })
vim.keymap.set('n', 'st', '<Esc>:<C-u>tabnew<CR>', { silent = true })
vim.keymap.set('n', 'ss', '<Esc>:<C-u>sp<CR>', { silent = true })
vim.keymap.set('n', 'sv', '<Esc>:<C-u>vs<CR>', { silent = true })
vim.keymap.set('n', '<C-n>', 'gt')
vim.keymap.set('n', '<C-p>', 'gT')

vim.keymap.set('n', '<Space>y', '"+yy')
vim.keymap.set('v', '<Space>y', '"+yy')
vim.keymap.set('n', '<Space>p', '"+p')
vim.keymap.set('v', '<Space>p', '"+p')

vim.keymap.set('t', '<C-w>n', '<C-\\><C-n>')

vim.keymap.set('n', '<C-s>', '<Esc>:syntax sync fromstart<CR>', { silent = true })

vim.cmd [[silent! colorscheme iceberg]]
