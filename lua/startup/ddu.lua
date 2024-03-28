local function lines()
  return vim.api.nvim_eval('&lines')
end
local function columns()
  return vim.api.nvim_eval('&columns')
end

vim.fn['ddu#custom#patch_global'] {
  ui = 'ff',
  sourceOptions = {
    _ = {
      matchers = { 'matcher_fzf' },
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
}

vim.fn['ddu#custom#patch_local']('file', {
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
  columnParams = {
    icon_filename = {
      defaultIcon = { icon = '' },
      padding = 0,
      pathDisplayOption = 'relative',
    },
  },
})

vim.fn['ddu#custom#patch_local']('rg', {
  sources = {{
    name = 'rg',
    params = {
      input = vim.fn.expand('<cword>'),
    },
  }},
  sourceParams = {
    rg = {
      args = {'--column', '--no-heading', '--color', 'never', '--json'},
    },
  },
})

vim.fn['ddu#custom#patch_local']('buffer', {
  sources = {{
    name = 'buffer',
  }},
})

vim.fn['ddu#custom#patch_local']('tab', {
  sources = {{
    name = 'tab',
    params = {
      format = 'tab|%n: %w',
    },
  }},
})

vim.fn['ddu#custom#patch_local']('mark', {
  sources = {{
    name = 'marks',
    params = {
      jumps = false,
    },
  }},
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
    vim.keymap.set('i', '<Esc>',
      [[<Esc><Cmd>call ddu#ui#do_action('leaveFilterWindow')<CR>]],
      { buffer = 0, silent = true }
    )
  end,
})

vim.keymap.set('n', ';f', [[<Cmd>call ddu#start({ 'name': 'file' })<CR>]],   { silent = true })
vim.keymap.set('n', ';r', [[<Cmd>call ddu#start({ 'name': 'rg' })<CR>]],     { silent = true })
vim.keymap.set('n', ';b', [[<Cmd>call ddu#start({ 'name': 'buffer' })<CR>]], { silent = true })
vim.keymap.set('n', ';t', [[<Cmd>call ddu#start({ 'name': 'tab' })<CR>]],    { silent = true })
vim.keymap.set('n', ';m', [[<Cmd>call ddu#start({ 'name': 'mark' })<CR>]],   { silent = true })
