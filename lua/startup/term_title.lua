local fnamemodify = vim.fn.fnamemodify
local split = vim.fn.split
local search = vim.fn.search
local getline = vim.fn.getline
local matchstr = vim.fn.matchstr
local substitute = vim.fn.substitute
local trim = vim.fn.trim
local printf = vim.fn.printf

local function set_term_title(prompt_pattern, max_length)
  local path = vim.api.nvim_buf_get_name(0)
  local shell = split(fnamemodify(path, ':t'), ':')[1]
  local term_path = printf('%s/%s', fnamemodify(path, ':h'), shell)

  local prompt_line = getline(search(prompt_pattern, 'nbcW'))
  local prompt = matchstr(prompt_line, prompt_pattern)
  local cmd = trim(substitute(string.sub(prompt_line, string.len(prompt) + 1, max_length), '/', '\\', 'g'))

  vim.api.nvim_buf_set_name(0, printf('%s:%s', term_path, cmd))
  vim.cmd['redrawtabline']()
end

vim.keymap.set('t', '<CR>', function()
  set_term_title('^% ', 24)
  return '<CR>'
end, { expr = true })
