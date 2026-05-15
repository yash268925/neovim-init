vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' }
})

vim.lsp.enable({
  'lua_ls',
  'ts_ls',
  'eslint',
  'cssls',
  'html',
  'jsonls',
  'tombi',
  'oxfmt',
  'oxlint',
  'dartls',
  'phpactor',
})

local keymaps = require('dotvim.utils').keymaps

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local buf = args.buf

    local function handle_hover()
      vim.lsp.buf.hover({
        border = 'single',
        max_height = 25,
        max_width = 80,
      })
    end

    local function handle_format()
      vim.lsp.buf.format({ async = false })
    end

    keymaps({
      { 'n', 'gd', vim.lsp.buf.definition,     { buffer = buf, silent = true } },
      { 'n', 'K',  handle_hover,               { buffer = buf, silent = true } },
      { 'n', 'gi', vim.lsp.buf.implementation, { buffer = buf, silent = true } },
      { 'n', 'gs', vim.lsp.buf.signature_help, { buffer = buf, silent = true } },
      { 'n', 'gr', vim.lsp.buf.references,     { buffer = buf, silent = true } },
      { 'n', 'gx', vim.diagnostic.open_float,  { buffer = buf, silent = true } },
      { 'n', 'gf', handle_format,              { buffer = buf, silent = true } },
      { 'n', 'gA', vim.lsp.buf.code_action,    { buffer = buf, silent = true } },
      { 'n', 'gn', vim.lsp.buf.rename,         { buffer = buf, silent = true } },
    })
  end
})
