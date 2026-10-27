local usercmd = vim.api.nvim_create_user_command

return function()
  usercmd('BoWin', 'bo 20sp | set wfh', {})
  usercmd('BoTer', 'bo 20sp | set wfh | ter', {})
end
