local autocmd = vim.api.nvim_create_autocmd

---@param group integer
return function(group)
  autocmd('TermOpen', {
    group = group,
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    end
  })
end
