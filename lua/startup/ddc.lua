local buf_config = {}

local function store_buffer_config()
  local bufnr = vim.api.nvim_get_current_buf()
  buf_config[bufnr] = vim.fn['ddc#custom#get_buffer']()
end

local function restore_buffer_config()
  local bufnr = vim.api.nvim_get_current_buf()
  local config = buf_config[bufnr]
  if config then
    vim.fn['ddc#custom#set_buffer'](config)
    buf_config[bufnr] = nil
  end
end

vim.fn['pum#set_option'] {
  use_complete = true,
  padding = true,
  max_height = 20,
  scrollbar_char = '┃',
}

vim.fn['ddc#custom#patch_global'] {
  ui = 'pum',
  autoCompleteEvents = {
    'InsertEnter', 'TextChangedI', 'TextChangedP', 'TextChangedT',
    'CmdlineEnter', 'CmdlineChanged',
  },
  backspaceCompletion = true,
  sources = {'nvim-lsp', 'rg', 'file'},
  sourceOptions = {
    _ = {
      ignoreCase = true,
      maxItems = 30,
      minAutoCompleteLength = 1,
      matchers = {'matcher_fuzzy'},
      sorters = {'sorter_fuzzy'},
      converters = {'converter_fuzzy'},
    },
    skkeleton = {
      mark = 'SKK',
      matchers = {'skkeleton'},
      sorters = {},
      minAutoCompleteLength = 2,
      isVolatile = true,
    },
    path = {
      mark = 'PATH',
      isVolatile = true,
    },
    file = {
      mark = 'FILE',
      isVolatile = true,
      forceCompletionPattern = '\\S/\\S*',
    },
    ['nvim-lsp'] = {
      mark = 'LSP',
      forceCompletionPattern = [[\.\w*|:\w*|->\w*]],
      sorters = {'sorter_lsp-kind'},
    },
    cmdline = {
      mark = 'CMD',
      isVolatile = true,
    },
    ['cmdline-history'] = {
      mark = 'CMD(H)',
    },
    rg = {
      mark = 'RG',
      minAutoCompleteLength = 4,
    },
  },
  sourceParams = {
    file = {
      smartCase = true,
    },
    path = {
      cmd = { 'fd', '--max-depth', '7', '-I', '-H' },
      absolute = false,
    },
  },
}

vim.api.nvim_create_autocmd('User', {
  pattern = 'skkeleton-enable-pre',
  callback = function()
    store_buffer_config()
    vim.fn['ddc#custom#patch_buffer']('sources', {'skkeleton'})
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'skkeleton-disable-pre',
  callback = function()
    restore_buffer_config()
  end,
})

vim.keymap.set('i', '<C-n>', '<Cmd>call pum#map#insert_relative(+1)<Cr>')
vim.keymap.set('i', '<C-p>', '<Cmd>call pum#map#insert_relative(-1)<Cr>')
vim.keymap.set('i', '<C-y>', '<Cmd>call pum#map#confirm()<Cr>')
vim.keymap.set('i', '<C-e>', '<Cmd>call pum#map#cancel()<Cr>')

vim.keymap.set('n', ':', function()
  vim.keymap.set('c', '<C-n>',   '<Cmd>call pum#map#insert_relative(+1)<CR>')
  vim.keymap.set('c', '<C-p>',   '<Cmd>call pum#map#insert_relative(-1)<CR>')
  vim.keymap.set('c', '<C-y>',   '<Cmd>call pum#map#confirm()<CR>')
  vim.keymap.set('c', '<C-e>',   '<Cmd>call pum#map#cancel()<CR>')

  store_buffer_config()

  vim.fn['ddc#custom#patch_buffer'] {
    cmdlineSources = { 'cmdline', 'path', 'cmdline-history' },
    sourceOptions = {
      _ = {
        minAutoCompleteLength = 0,
      },
    },
  }

  vim.api.nvim_create_autocmd('User', {
    pattern = 'DDCCmdlineLeave',
    callback = function()
      vim.cmd[[
        silent! cunmap <C-n>
        silent! cunmap <C-p>
        silent! cunmap <C-y>
        silent! cunmap <C-e>
      ]]

      restore_buffer_config()
    end,
    once = true,
  })

  vim.fn['ddc#enable_cmdline_completion']()

  return ':'
end, { expr = true })

vim.api.nvim_create_autocmd('CompleteDone', {
  callback = function()
    print('test')
    vim.cmd.pclose({ bang = true })
  end
})

vim.fn['ddc#enable']()
vim.fn['popup_preview#enable']()
