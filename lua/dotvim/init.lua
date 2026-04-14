require('dotvim.configs')
require('dotvim.keymaps')
require('dotvim.plugins')
require('dotvim.pickers')

vim.cmd.packadd('nohlsearch')

require('dotvim.autocmds')
require('dotvim.usercmds')

require('dotvim.experimental')
