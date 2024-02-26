local M = {}

function M.split(str, ts)
  -- 引数がないときは空tableを返す
  if ts == nil then return {} end

  local t = {} ; 
  local i = 1
  for s in string.gmatch(str, "([^"..ts.."]+)") do
    t[i] = s
    i = i + 1
  end

  return t
end

return M
