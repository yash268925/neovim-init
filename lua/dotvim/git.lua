local specs = require('dotvim._lib.specs')

return require('dotvim._lib.feature').define({
  name = 'git',
  specs = {
    { src = 'https://github.com/vim-denops/denops.vim' },
    { src = 'https://github.com/lambdalisue/vim-gin' },
    { src = 'https://github.com/echasnovski/mini.diff' },
    specs.nightfox,
  },
  setup = function()
    local palette = require('dotvim._lib.palette')

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

    require('mini.diff').setup({
      view = {
        style = 'sign',
      },
    })
  end,
})
