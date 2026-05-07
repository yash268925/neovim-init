require('dotvim.configs')
require('dotvim.keymaps')
require('dotvim.plugins')

vim.cmd.packadd('nohlsearch')

require('dotvim.autocmds')
require('dotvim.usercmds')

require('dotvim.experimental')
