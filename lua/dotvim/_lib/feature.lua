local M = {}

---@type table<string, true>
local enabled_features = {}

---@class dotvim.FeatureDef
---@field name string
---@field specs (string | vim.pack.Spec)[]
---@field defaults? table
---@field setup fun(opts: table)

---@class dotvim.Feature
---@field specs (string | vim.pack.Spec)[]
---@field setup fun(opts?: table)

-- 2 回目以降の setup は opts ごと無視する。各プラグインの setup が再実行に耐える保証がないため。
---@param def dotvim.FeatureDef
---@return dotvim.Feature
function M.define(def)
  local feature = { specs = def.specs }

  function feature.setup(opts)
    if enabled_features[def.name] then
      return
    end
    -- 本体の途中で失敗しても再実行させないよう、先に記録する
    enabled_features[def.name] = true

    if #feature.specs > 0 then
      vim.pack.add(feature.specs)
    end
    def.setup(vim.tbl_deep_extend('force', def.defaults or {}, opts or {}))
  end

  return feature
end

---@param name string
---@return boolean
function M.enabled(name)
  return enabled_features[name] == true
end

return M
