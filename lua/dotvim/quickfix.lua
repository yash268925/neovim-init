return require('dotvim._lib.feature').define({
  name = 'quickfix',
  specs = {
    { src = 'https://github.com/kyoh86/vim-ripgrep' },
    { src = 'https://github.com/drmingdrmer/vim-toggle-quickfix' },
    { src = 'https://github.com/itchyny/vim-qfedit' },
  },
  setup = function()
    vim.api.nvim_create_user_command('Grep', ':call ripgrep#search(<q-args>)', {
      bang = true,
      nargs = '*',
      complete = 'file',
    })

    require('dotvim._lib.utils').keymaps({
      { 'n', '<C-q><C-l>', '<Plug>window:quickfix:loop' },
    })
  end,
})
