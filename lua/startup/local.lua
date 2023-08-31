vim.api.nvim_create_autocmd('BufEnter', {
  callback = function(ev)
    local buf = ev.buf
    local rc = vim.fs.find('.nvim/init.lua', {
      upward = true,
      stop = vim.uv.os_homedir(),
      path = vim.fs.dirname(vim.api.nvim_buf_get_name(buf)),
    })
    if rc[1] then
      dofile(rc[1])
    end
  end
})
