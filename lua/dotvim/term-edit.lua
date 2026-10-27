return require('dotvim._lib.feature').define({
  name = 'term-edit',
  specs = {
    { src = 'https://github.com/chomosuke/term-edit.nvim' },
  },
  defaults = {
    prompt_end = '❯❮ ',
  },
  setup = function(opts)
    ---@diagnostic disable-next-line: missing-fields
    require('term-edit').setup({
      prompt_end = opts.prompt_end,
    })
  end,
})
