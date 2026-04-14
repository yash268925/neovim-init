local autocmd = vim.api.nvim_create_autocmd

autocmd('TermOpen', {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end
})
