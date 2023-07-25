local function copy(lines)
  return vim.fn.OSCYank(vim.fn.join(lines, '\n'))
end

local function paste()
  return {vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('')}
end

vim.g.oscyank_term = 'kitty'

vim.g.clipboard = {
  name = 'osc52',
  copy = {
    ['+'] = copy,
    ['*'] = copy,
  },
  paste = {
    ['+'] = paste,
    ['*'] = paste,
  },
}
