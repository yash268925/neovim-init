return require('dotvim._lib.feature').define({
  name = 'ja-doc',
  specs = {
    { src = 'https://github.com/vim-jp/vimdoc-ja' },
  },
  setup = function()
    vim.opt.helplang:prepend('ja')
  end,
})
