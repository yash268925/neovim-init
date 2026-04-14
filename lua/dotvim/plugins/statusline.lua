local pal = require('dotvim.plugins.colorscheme').palette

local color = {
  normal  = pal.blue.dim,
  insert  = pal.blue.bright,
  visual  = pal.orange.base,
  replace = pal.red.base,
  command = pal.yellow.base,
}

local u = require('dotvim.utils')
local hl_set, hl_link = u.hl_set, u.hl_link

hl_link({ StatusLine = 'Normal' })
hl_set({
  StatusLineNormal  = { fg = color.normal,  bg = 'NONE' },
  StatusLineInsert  = { fg = color.insert,  bg = 'NONE' },
  StatusLineVisual  = { fg = color.visual,  bg = 'NONE' },
  StatusLineReplace = { fg = color.replace, bg = 'NONE' },
  StatusLineCommand = { fg = color.command, bg = 'NONE' },
})

local o = vim.opt

o.laststatus = 3
o.statusline = '%!v:lua.Statusline()'

---バッファが保存されていなければtrueを返す
local function is_buffer_unsave(bufno)
  return (
    vim.fn.bufexists(bufno) == 1                                  -- バッファ存在し
    and vim.fn.buflisted(bufno) == 1                              -- listedで
    and vim.fn.getbufvar(bufno, 'buftype') == ''                  -- buftype == ''で
    and vim.fn.filereadable(vim.fn.expand('#' .. bufno .. ':p'))  -- fileがreadableで
    and bufno ~= vim.fn.bufnr('%')                                -- カレントバッファでなく
    and vim.fn.getbufvar(bufno, '&modified') == 1                 -- modifiedならば
  )
end

---アクティブでないバッファのうち、保存されていないものの数を返す
local function get_modified_bg_bufs_count()
  local count = 0
  for bufnr = 1, vim.fn.bufnr('$') do
    if is_buffer_unsave(bufnr) then
      count = count + 1
    end
  end
  return count
end

---ライン色
local function get_line_hl(m)
  m = string.lower(m or '')
  if m == 'n' then
    return 'StatusLineNormal'
  elseif m == 'i' then
    return 'StatusLineInsert'
  elseif m == 'c' then
    return 'StatusLineCommand'
  elseif m == 'v' or m == '^V' or m == 's' then
    return 'StatusLineVisual'
  elseif m == 'r' then
    return 'StatusLineReplace'
  end
  return 'StatusLine'
end

local components = {
  left = {
    -- Modified mark
    function()
      return {
        { text = vim.o.modified and '+' or '', hl = 'Normal' }
      }
    end,
    -- Modified buffer count
    function()
      local mc = get_modified_bg_bufs_count()
      if mc == 0 then
        return {}
      end
      return {
        { text = string.format('(+%d)', mc), hl = 'Normal' }
      }
    end,
  },
  right = {
    -- Filepath
    function()
      local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
      if vim.startswith(path, 'gin') then
        path = vim.split(path, ';')[1]
      end
      local icon, hl = require('dotvim.plugins.mini').icons.get('file', path)
      return {
        { text = icon, hl = hl },
        { text = path, hl = 'Normal' },
      }
    end,
    -- Cursor position
    function()
      local line = vim.fn.line('.')
      local col = vim.fn.col('.')
      return {
        { text = string.format('%2d:%2d', line, col), hl = 'Normal' }

      }
    end,
  }
}

local function genbar(line_hl)
  return function(count)
    return { text = string.rep('━', count), hl = line_hl }
  end
end

function _G.Statusline()
  local bar = genbar(get_line_hl(vim.fn.mode()))

  local left_parts = vim.iter(components.left)
    :map(function(v) return v() end)
    :flatten():totable()
  local right_parts = vim.iter(components.right)
    :map(function(v) return v() end)
    :flatten():totable()

  local cw = vim.o.columns
  local lw = vim.fn.strdisplaywidth(
    vim.iter(left_parts):map(function(v) return v.text end):join(' ')
  )
  local rw = vim.fn.strdisplaywidth(
    vim.iter(right_parts):map(function(v) return v.text end):join(' ')
  )

  local parts = {
    { bar(1) },
    left_parts,
    { bar(cw - (lw + rw) - 2 - 4) },
    right_parts,
    { bar(1) }
  }

  return vim.iter(parts)
    :flatten()
    :map(function(v) return string.format('%%#%s#%s', v.hl, v.text) end)
    :join(' ')
end
