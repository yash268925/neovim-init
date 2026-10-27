local deck = require('deck')
local ignore_globs = require('dotvim.picker.ignore_globs')

deck.register_start_preset({
  name = 'files',
  args = {
    ['--root'] = {
      require = false,
      default = false,
      complete = function(prefix)
        return vim.fn.getcompletion(prefix, 'dir')
      end,
    },
  },
  start = function(args)
    deck.start({
      require('deck.builtin.source.files')({
        root_dir = args['--root'] or vim.fn.getcwd(),
        ignore_globs = ignore_globs,
      }),
    })
  end
})

vim.api.nvim_create_autocmd('User', {
  group = 'dotvim.picker',
  pattern = 'DeckStart:files',
  callback = function(e)
    local ctx = e.data.ctx --[[@as deck.Context]]

    ctx.prompt()
  end
})
