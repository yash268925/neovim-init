local specs = require('dotvim._lib.specs')

return require('dotvim._lib.feature').define({
  name = 'ui',
  specs = {
    { src = 'https://github.com/j-hui/fidget.nvim' },
    specs.mini_icons,
    { src = 'https://github.com/echasnovski/mini.indentscope' },
    specs.nightfox,
    { src = 'https://github.com/kevinhwang91/promise-async' },
    { src = 'https://github.com/kevinhwang91/nvim-ufo' },
  },
  setup = function()
    vim.api.nvim_create_augroup('dotvim.ui', { clear = true })

    -- 以降の setup が出す通知も fidget で表示するため最初に読み込む
    require('dotvim.ui.fidget')
    require('dotvim._lib.mini').icons()
    require('dotvim.ui.indentscope')
    require('dotvim.ui.colorscheme')
    require('dotvim.ui.statusline')
    require('dotvim.ui.ufo')
  end,
})
