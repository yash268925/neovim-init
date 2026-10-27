---@param hls table<string, vim.api.keyset.highlight>
local function hl_set(hls)
  for group, value in pairs(hls) do
    vim.api.nvim_set_hl(0, group, value)
  end
end

---@param links table<string, string | integer>
local function hl_link(links)
  for from, to in pairs(links) do
    vim.api.nvim_set_hl(0, from, { link = to })
  end
end

---@param maps table<string | string[], string, string | function, vim.keymap.set.Opts?>[]
local function keymaps(maps)
  for _, map in ipairs(maps) do
    local modes, key, action, opts = unpack(map)
    modes = type(modes) == 'table' and modes or { modes }
    for _, mode in ipairs(modes) do
      vim.keymap.set(mode, key, action, opts)
    end
  end
end

return {
  hl_set = hl_set,
  hl_link = hl_link,
  keymaps = keymaps,
}
