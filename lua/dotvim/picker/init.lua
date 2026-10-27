local specs = require('dotvim._lib.specs')

return require('dotvim._lib.feature').define({
  name = 'picker',
  specs = {
    specs.mini_icons,
    { src = 'https://github.com/hrsh7th/nvim-deck' },
  },
  setup = function()
    vim.api.nvim_create_augroup('dotvim.picker', { clear = true })

    -- nvim-deck は mini.icons を require できればアイコンを表示する
    require('dotvim._lib.mini').icons()
    require('dotvim.picker.deck')
  end,
})
