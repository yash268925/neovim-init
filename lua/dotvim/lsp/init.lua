return require('dotvim._lib.feature').define({
  name = 'lsp',
  specs = {
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  },
  defaults = {
    servers = {
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
    },
  },
  setup = function(opts)
    vim.api.nvim_create_augroup('dotvim.lsp', { clear = true })

    vim.lsp.enable(opts.servers)
    require('dotvim.lsp.keymaps')
    require('dotvim.lsp.treesitter')
  end,
})
