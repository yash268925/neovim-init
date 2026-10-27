local indentscope = require('mini.indentscope')
indentscope.setup({
  draw = {
    delay = 30,
    animation = function() return 8 end,
  },
  symbol = '┆',
})

vim.api.nvim_create_autocmd('TermOpen', {
  group = 'dotvim.ui',
  callback = function(args)
    vim.b[args.buf].miniindentscope_disable = true
  end,
})
