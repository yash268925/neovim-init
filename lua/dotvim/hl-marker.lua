return require('dotvim._lib.feature').define({
  name = 'hl-marker',
  specs = {
    { src = 'https://github.com/t9md/vim-quickhl' },
  },
  setup = function()
    require('dotvim._lib.utils').keymaps({
      { { 'n', 'x' }, '<Space>m', '<Plug>(quickhl-manual-this)' },
      { { 'n', 'x' }, '<Space>M', '<Plug>(quickhl-manual-reset)' },
      { 'n',          '<Space>j', '<Plug>(quickhl-cword-toggle)' },
    })
  end,
})
