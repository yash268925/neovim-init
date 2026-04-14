vim.pack.add({
  { src = 'https://github.com/kyoh86/vim-ripgrep' },
})

vim.api.nvim_create_user_command('Grep', ':call ripgrep#search(<q-args>)', {
  bang = true,
  nargs = '*',
  complete = 'file',
})
