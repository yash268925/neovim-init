vim.pack.add({ 'https://github.com/hrsh7th/nvim-deck' })

local deck = require('deck')
local kit = require('deck.kit')

local ignore_globs = {
  '**/node_modules/**',
  '**/.git/**',
}

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

deck.register_start_preset('buffers', function()
  deck.start({
    require('deck.builtin.source.buffers')(),
  })
end)

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
      view = function()
        return require('deck.builtin.view.drawer_picker')({ auto_resize = true, min_width = option.width })
      end,
      dedup = false,
      history = false,
      disable_decorators = { 'filename', 'signs' },
    })
  end,
})


vim.api.nvim_create_autocmd('User', {
  pattern = 'DeckStart',
  callback = function(e)
    local ctx = e.data.ctx --[[@as deck.Context]]

    ctx.keymap('n', '<Tab>', deck.action_mapping('choose_action'))
    ctx.keymap('n', '<C-l>', deck.action_mapping('refresh'))
    ctx.keymap('n', 'i', deck.action_mapping('prompt'))
    ctx.keymap('n', '@', deck.action_mapping('toggle_select'))
    ctx.keymap('n', '*', deck.action_mapping('toggle_select_all'))
    ctx.keymap('n', 'P', deck.action_mapping('toggle_preview_mode'))
    ctx.keymap('n', '<CR>', deck.action_mapping('default'))
    ctx.keymap('n', 'q', function() ctx.hide() end)
    ctx.keymap('n', '<Esc>', function() ctx.hide() end)
  end
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'DeckStart:buffers',
  callback = function(e)
    local ctx = e.data.ctx --[[@as deck.Context]]

    ctx.keymap('n', 'd', deck.action_mapping('delete_buffer'))
    ctx.keymap('n', '<CR>', deck.action_mapping('open'))

    ctx.prompt()
  end
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'DeckStart:files',
  callback = function(e)
    local ctx = e.data.ctx --[[@as deck.Context]]

    ctx.prompt()
  end
})

vim.api.nvim_create_autocmd('User', {
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

deck.register_start_preset({
  name = 'lsp-ref',
  start = function()
    deck.start({
      name = 'lsp-ref',
      execute = function(ctx)
        local bufnr = ctx.get_prev_buf()
        local win = ctx.get_prev_win()
        local cursor = vim.api.nvim_win_get_cursor(win)

        local params = {
          textDocument = { uri = vim.uri_from_bufnr(bufnr) },
          position = { line = cursor[1] - 1, character = cursor[2] },
          context = { includeDeclaration = true },
        }

        local cancel = vim.lsp.buf_request_all(bufnr, 'textDocument/references', params, function(results)
          if ctx.aborted() then return end

          for _, result in pairs(results) do
            for _, location in ipairs(result.result or {}) do
              local filename = vim.uri_to_fname(location.uri)
              local lnum = location.range.start.line + 1
              local col_num = location.range.start.character + 1

              local line_text = ''
              local buf = vim.fn.bufnr(filename)
              if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
                local lines = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)
                line_text = (lines[1] or ''):gsub('^%s+', '')
              else
                local ok, lines = pcall(vim.fn.readfile, filename)
                if ok and lines[lnum] then
                  line_text = lines[lnum]:gsub('^%s+', '')
                end
              end

              ctx.item({
                display_text = {
                  { ('%s:%s:%s '):format(vim.fn.fnamemodify(filename, ':~:.'), lnum, col_num) },
                  { line_text, 'Comment' },
                },
                data = {
                  filename = filename,
                  lnum = lnum,
                  col = col_num,
                },
              })
            end
          end

          ctx.done()
        end)

        if type(cancel) == 'function' then
          ctx.on_abort(cancel)
        end
      end,
      actions = {
        require('deck').alias_action('default', 'open'),
      },
    })
  end,
})

local keymaps = require('dotvim.utils').keymaps

keymaps({
  { 'n', ';b', '<Cmd>Deck buffers<CR>' },
  { 'n', ';f', '<Cmd>Deck files<CR>' },
  { 'n', ';g', '<Cmd>Deck grep<CR>' },
  { 'n', ';e', '<Cmd>Deck explorer<CR>' },
  { 'n', ';r', '<Cmd>Deck lsp-ref<CR>' },
})
