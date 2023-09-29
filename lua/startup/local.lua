local once = {}

vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter' }, {
  callback = function(ev)
    local buf = ev.buf
    local rc = vim.fs.find('.nvim/init.lua', {
      upward = true,
      stop = vim.uv.os_homedir(),
      path = vim.api.nvim_buf_get_name(buf),
    })[1]
    if rc then
      local rcmod = dofile(rc)
      local rconce = rcmod and rcmod['once'] or nil
      local fp = vim.loop.fs_realpath(rc)
      if rconce and once[fp] == nil then
        once[fp] = true
        rconce()
      end
    end
  end
})
