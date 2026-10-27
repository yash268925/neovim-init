local deck = require('deck')
local ignore_globs = require('dotvim.picker.ignore_globs')

deck.register_start_preset({
  name = 'grep',
  args = {
    ['--sort'] = {
      required = false,
      default = 'false',
      complete = function()
        return { 'true', 'false' }
      end,
    },
    ['--root'] = {
      require = false,
      default = false,
      complete = function(prefix)
        return vim.fn.getcompletion(prefix, 'dir')
      end,
    },
  },
  start = function(args)
    local pattern = vim.fn.input('grep: ')
    deck.start(
      require('deck.builtin.source.grep')({
        root_dir = args['--root'] or vim.fn.getcwd(),
        ignore_globs = ignore_globs,
        sort = args['--sort'] == 'true',
      }),
      {
        query = #pattern > 0 and (pattern .. '  ') or '',
      }
    )
  end
})
