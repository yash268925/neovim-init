local util = require('lsp')
local navic = require('nvim-navic')

util.on_attach(function(client, buf)
  vim.keymap.set('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'gs', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'gx', '<Cmd>lua vim.diagnostic.open_float()<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'g[', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'g]', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', { buffer = buf, silent = true })

  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, buf)
    vim.wo.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
  end
end)

require('startup.lsp.lua')
require('startup.lsp.js')
require('startup.lsp.php')
