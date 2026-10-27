local specs = require('dotvim._lib.specs')

local loaded = {}

---@param name string
---@param spec vim.pack.Spec
local function load(name, spec)
  if not loaded[name] then
    vim.pack.add({ spec })
    local mod = require(name)
    mod.setup()
    loaded[name] = mod
  end
  return loaded[name]
end

return {
  icons = function() return load('mini.icons', specs.mini_icons) end,
  bufremove = function() return load('mini.bufremove', specs.mini_bufremove) end,
}
