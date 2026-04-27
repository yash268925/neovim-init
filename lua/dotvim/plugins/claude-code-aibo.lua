vim.pack.add({
  { src = 'https://github.com/lambdalisue/nvim-aibo' }
})

local aibo = require('aibo')

aibo.setup()

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'aibo-*',
  callback = function()
    vim.wo.winfixwidth = true
  end,
})

local function toggle_claude()
  local width = math.floor(vim.o.columns * 1 / 3)
  vim.cmd(string.format('Aibo -stay -toggle -opener="botright %dvsplit" claude', width))
end

local keymaps = require('dotvim.utils').keymaps

keymaps({
  { 'n', ';c', toggle_claude },
})
