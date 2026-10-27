local ts = require('nvim-treesitter')

ts.setup({
  ensure_installed = {
    'css', 'html', 'javascript', 'lua',
    'markdown', 'php', 'tsx', 'typescript', 'vim',
    'xml'
  },
  highlight = { enable = true },
  indent = { enable = true },
})
