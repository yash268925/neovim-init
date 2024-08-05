local rc = vim.fs.find('.nvim/init.lua', {
  upward = true,
  stop = vim.uv.os_homedir(),
  path = vim.loop.cwd(),
})[1]
if rc then
  vim.cmd('set rtp+=' .. vim.fs.dirname(rc))
end
