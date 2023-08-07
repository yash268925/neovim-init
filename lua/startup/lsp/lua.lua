local util = require('lsp')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua',
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.start({
      name = 'lua_ls',
      capabilities = vim.lsp.protocol.make_client_capabilities(),
      cmd = { 'lua-language-server' },
      root_dir = util.find_root(buf),
    })
    vim.lsp.buf_attach_client(buf, client)
  end,
})
