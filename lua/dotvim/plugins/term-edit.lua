vim.pack.add({
  { src = 'https://github.com/chomosuke/term-edit.nvim' }
})

local termedit = require('term-edit')

---@diagnostic disable-next-line: missing-fields
termedit.setup({
  prompt_end = '❯❮ ',
})
