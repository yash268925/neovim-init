local deck = require('deck')
local kit = require('deck.kit')
local ignore_globs = require('dotvim.picker.ignore_globs')

local function get_project_root(path)
  return kit.findup(path, { '.git', 'package.json', 'tsconfig.json' })
end

local function get_buffer_path(bufnr)
  local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
  if vim.fn.isdirectory(path) == 1 or vim.fn.filereadable(path) == 1 then
    return path
  end
  return vim.fn.getcwd()
end

local function to_dir(path)
  if vim.fn.filereadable(path) == 1 then
    return vim.fs.dirname(path)
  end
  return path
end

deck.register_start_preset({
  name = 'explorer',
  args = {
    ['--width'] = {
      required = false,
    },
    ['--root'] = {
      required = false,
      complete = function(prefix)
        return vim.fn.getcompletion(prefix, 'dir')
      end,
    },
    ['--reveal'] = {
      required = false,
    },
  },
  start = function(args)
    local buffer_path = get_buffer_path(vim.api.nvim_get_current_buf())

    local option = {
      width = tonumber(args['--width']) or 40,
      root = args['--root'] or get_project_root(buffer_path) or to_dir(buffer_path),
      reveal = args['--reveal'] or get_buffer_path(vim.api.nvim_get_current_buf()),
    }

    deck.start({
      require('deck.builtin.source.explorer')({
        cwd = option.root,
        mode = 'drawer',
        reveal = option.reveal or option.root,
        narrow = {
          enable = true,
          ignore_globs = ignore_globs,
        },
      }),
    }, {
      get_view = function()
        return require('deck.builtin.view.drawer_picker')({ auto_resize = true, min_width = option.width })
      end,
      dedup = false,
      history = false,
      disable_decorators = { 'filename', 'signs' },
    })
  end,
})

vim.api.nvim_create_autocmd('User', {
  group = 'dotvim.picker',
  pattern = 'DeckStart:explorer',
  callback = function(e)
    local ctx = e.data.ctx --[[@as deck.Context]]
    ctx.keymap('n', 'h', deck.action_mapping('explorer.collapse'))
    ctx.keymap('n', 'l', deck.action_mapping('explorer.expand'))
    ctx.keymap('n', '.', deck.action_mapping('explorer.toggle_dotfiles'))
    ctx.keymap('n', 'y', deck.action_mapping('explorer.clipboard.save_copy'))
    ctx.keymap('n', 'x', deck.action_mapping('explorer.clipboard.save_move'))
    ctx.keymap('n', 'p', deck.action_mapping('explorer.clipboard.paste'))
    ctx.keymap('n', 'N', deck.action_mapping('create'))
    ctx.keymap('n', 'R', deck.action_mapping('rename'))
    ctx.keymap('n', 'd', deck.action_mapping('explorer.delete'))
  end
})
