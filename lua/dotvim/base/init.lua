local specs = require('dotvim._lib.specs')

return require('dotvim._lib.feature').define({
  name = 'base',
  specs = { specs.mini_bufremove },
  defaults = {
    shell = 'fish',
    ui2 = true,
  },
  setup = function(opts)
    require('dotvim.base.options')(opts)
    require('dotvim.base.keymaps')()

    vim.cmd.packadd('nohlsearch')
    vim.cmd.packadd('nvim.undotree')

    local group = vim.api.nvim_create_augroup('dotvim.base', { clear = true })
    require('dotvim.base.autocmds')(group)
    require('dotvim.base.usercmds')()

    if opts.ui2 then
      require('vim._core.ui2').enable()
    end
  end,
})
