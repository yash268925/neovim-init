require('dotvim.plugins.denops')

vim.pack.add({
  { src = 'https://github.com/lambdalisue/vim-gin' },
})

local palette = require('dotvim.plugins.colorscheme').palette

local fg_color = palette.fg3

local log_line_parts = {
  '%C(' .. fg_color .. ')%h',
  '%C(auto)%d ',
  '%s ',
  '%C(' .. fg_color .. ')- ',
  '[%C(bold)%an%Creset%C(' .. fg_color .. ') %ai]%Creset'
}

vim.g.gin_log_persistent_args = {
  '--graph',
  '--oneline',
  '--decorate=full',
  '--date-order',
  '--format=' .. table.concat(log_line_parts),
}
