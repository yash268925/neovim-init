vim.pack.add({
  { src = 'https://github.com/uga-rosa/ccc.nvim' }
})

local ccc = require('ccc')

ccc.setup({
  highlighter = {
    auto_enable = true,
    lsp = true,
    filetypes = { 'html', 'css', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  },
  pickers = {
    ccc.picker.hex,
    ccc.picker.css_hsl,
  },
})
