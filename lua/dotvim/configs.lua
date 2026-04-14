local o = vim.opt

o.title = false
o.cursorline = true
o.number = true
o.relativenumber = true
o.timeoutlen = 300
o.updatetime = 300
o.wildmenu = false
o.modeline = true
o.numberwidth = 4
o.laststatus = 3
o.cmdheight = 0
o.showtabline = 0
o.termguicolors = true
o.winblend = 0
o.pumblend = 0
o.sessionoptions = {
  'curdir', 'folds', 'globals', 'help', 'tabpages', 'terminal', 'winsize'
}
o.swapfile = false
o.undofile = true
o.backup = false
o.writebackup = false
o.hlsearch = true
o.ignorecase = true
o.smartindent = true
o.clipboard:append('unnamedplus')
o.equalalways = true
o.guicursor:append('c:ver10')
o.mouse = ''
o.shada = { "'50", ':20', '<1000', 's10', 'h' }
o.exrc = true

o.expandtab = true
o.tabstop = 2
o.softtabstop = -1
o.shiftwidth = 0

o.list = true
o.listchars = { eol = '$', tab = '>-', space = '.' }

o.winborder = 'single'

vim.cmd.filetype('plugin indent on')
