local specs = require('dotvim._lib.specs')

return require('dotvim._lib.feature').define({
  name = 'picker',
  specs = {
    specs.mini_icons,
    { src = 'https://github.com/echasnovski/mini.files' },
    { src = 'https://github.com/echasnovski/mini.pick' },
    { src = 'https://github.com/echasnovski/mini.extra' },
    { src = 'https://github.com/hrsh7th/nvim-deck' },
  },
  setup = function()
    vim.api.nvim_create_augroup('dotvim.picker', { clear = true })

    require('dotvim.picker.mini')
    require('dotvim.picker.deck')
  end,
})
