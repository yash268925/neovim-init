local function lines()
  return vim.api.nvim_eval('&lines')
end
local function columns()
  return vim.api.nvim_eval('&columns')
end

vim.fn['ddu#custom#patch_global'] {
  ui = 'ff',
  sources = {{
    name = 'file_rec',
    params = {
      ignoredDirectories = {'.git', 'node_modules', 'vendor'},
    },
  }},
  sourceOptions = {
    _ = {
      matchers = {'matcher_hidden', 'matcher_fzf'},
    },
    file_rec = {
      columns = {'icon_filename'},
    },
  },
  kindOptions = {
    file = {
      defaultAction = 'open',
    },
  },
  uiParams = {
    ff = {
      split = 'floating',
      floatingBorder = 'single',
      filterFloatingPosition = 'top',
      startFilter = false,
      prompt = '> ',
      winHeight = math.floor(lines() * 0.8),
      winRow = math.floor(lines() * 0.1),
      winWidth = math.floor(columns() * 0.8),
      winCol = math.floor(columns() * 0.1),
      previewWidth = math.floor(columns() * 0.8 / 2),
    },
  },
  filterParams = {
    matcher_fzf = {
      highlightMatched = 'Search',
    },
  },
  columnParams = {
    icon_filename = {
      defaultIcon = { icon = '' },
      padding = 0,
      pathDisplayOption = 'relative',
    },
  },
}

vim.fn['ddu#custom#patch_local']('rg', {
  sourceParams = {
    rg = {
      args = {'--column', '--no-heading', '--color', 'never', '--json'},
    },
  },
  uiParams = {
    ff = {
      startFilter = false,
    },
  },
})

vim.fn['ddu#custom#patch_local']('buffer', {
  uiParams = {
    ff = {
      startFilter = false,
    },
  },
})

vim.api.nvim_create_autocmd({'TabEnter', 'CursorHold', 'FocusGained'}, {
  command = [[call ddu#ui#do_action('checkItems')]],
  buffer = 0,
})

local function toggle(array, needle)
  local idx = -1
  for k, v in ipairs(array) do
    if v == needle then idx = k end
  end
  if idx ~= -1 then
    table.remove(array, idx)
  else
    table.insert(array, needle)
  end
  print(vim.inspect(array))
  return array
end

local function toggleHidden(ui_name)
  local cur = vim.fn['ddu#custom#get_current'](ui_name)
  local opts = cur['sourceOptions'] or {}
  local opts_all = opts['_'] or {}
  local matchers = opts_all['matchers'] or {}
  return toggle(matchers, 'matcher_hidden')
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'ddu-ff',
  callback = function()
    vim.keymap.set('n', '<Enter>',
      [[<Cmd>call ddu#ui#do_action('itemAction', {'name': 'open'})<CR>]],
      { buffer = 0, silent = true }
    )
    vim.keymap.set('n', '<Esc>',
      [[<Cmd>call ddu#ui#do_action('quit')<CR>]],
      { buffer = 0, silent = true }
    )
    vim.keymap.set('n', 'f',
      [[<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>]],
      { buffer = 0, silent = true }
    )
    vim.keymap.set('n', 'd',
      [[<Cmd>call ddu#ui#do_action('itemAction', {'name': 'delete'})<CR>]],
      { buffer = 0, silent = true }
    )
    vim.keymap.set('n', '.', function()
      vim.fn['ddu#ui#do_action']('updateOptions', {
        sourceOptions = {
          _ = {
            matchers = toggleHidden(vim.b.ddu_ui_name)
          },
        },
      })
      vim.fn['ddu#ui#do_action']('checkItems')
    end, { expr = true, buffer = 0, silent = true })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'ddu-ff-filter',
  callback = function()
    vim.keymap.set('i', '<Enter>',
      [[<Esc><Cmd>call ddu#ui#do_action('leaveFilterWindow')<CR>]],
      { buffer = 0, silent = true }
    )
    vim.keymap.set('i', 'q',
      [[<Esc><Cmd>call ddu#ui#do_action('quit')<CR>]],
      { buffer = 0, silent = true }
    )
  end,
})

vim.keymap.set('n', ';f', [[<Cmd>call ddu#start({})<CR>]], { silent = true })

vim.keymap.set('n', ';r', function()
  vim.fn['ddu#start'] {
    name = 'rg',
    sources = {{
      name = 'rg',
      params = {
        input = vim.fn.expand('<cword>'),
      },
    }},
  }
end, { silent = true })

vim.keymap.set('n', ';b', function()
  vim.fn['ddu#start'] {
    name = 'buffer',
    sources = {{
      name = 'buffer',
    }},
  }
end, { silent = true }) 

vim.keymap.set('n', 'to', function()
  vim.fn['ddu#start'] {
    name = 'filer',
    ui = 'filer',
    resume = true,
    sources = {{
      name = 'file',
      params = {
        ignoredDirectories = {'.git', 'node_modules', 'vendor'},
      },
    }},
    uiParams = {
      filer = {
        split = 'no',
        statusline = false,
        previewFloating = true,
        previewFloatingBorder = 'single',
        previewHeight = 40,
        previewWidth = 80,
        previewRow = 10,
        previewCol = 10,
      },
    },
    sourceOptions = {
      _ = {
        columns = {'icon_filename', 'filename'},
      },
    },
    kindOptions = {
      file = {
        defaultAction = 'open',
      },
    },
    actionOptions = {
      loclist = {
        quit = false,
      },
    },
  }
end, { silent = true })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'ddu-filer',
  callback = function()
    vim.keymap.set('n', 'l',
      [[<Cmd>call ddu#ui#do_action('expandItem')<CR>]],
      { buffer = 0, silent = true }
    )
    vim.keymap.set('n', 'h',
      [[<Cmd>call ddu#ui#do_action('collapseItem')<CR>]],
      { buffer = 0, silent = true }
    )

    vim.keymap.set('n', 'p',
      [[<Cmd>call ddu#ui#do_action('togglePreview')<CR>]],
      { buffer = 0, silent = true }
    )
    vim.keymap.set('n', '<Enter>',
      [[<Cmd>call ddu#ui#do_action('itemAction', {'name': 'open'})<CR>]],
      { buffer = 0, silent = true }
    )

    vim.keymap.set('n', '<Space>',
      [[<Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>]],
      { buffer = 0, silent = true }
    )

    vim.keymap.set('n', 'i',
      [[<Cmd>call ddu#ui#do_action('itemAction', {'name': 'newFile'})<CR>]],
      { buffer = 0, silent = true }
    )
    vim.keymap.set('n', 'o',
      [[<Cmd>call ddu#ui#do_action('itemAction', {'name': 'newDirectory'})<CR>]],
      { buffer = 0, silent = true }
    )
    vim.keymap.set('n', 'a',
      [[<Cmd>call ddu#ui#do_action('inputAction')<CR>]],
      { buffer = 0, silent = true }
    )

    vim.keymap.set('n', '.', function()
      vim.fn['ddu#ui#do_action']('updateOptions', {
        sourceOptions = {
          _ = {
            matchers = toggleHidden(vim.b.ddu_ui_name)
          },
        },
      })
      vim.fn['ddu#ui#do_action']('checkItems')
    end, { expr = true, buffer = 0, silent = true })
  end,
})
