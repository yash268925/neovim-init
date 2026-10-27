--- cmp-kit CompletionSource for nvim-aibo's live "/" slash-command probe.
--- Reuses whatever `aibo.completion.<module_name>` (claude/codex/gemini) has
--- already probed and cached (see :h aibo-live-completion) -- this file does
--- no spawning/caching of its own, only converts aibo's entries into LSP
--- completion items for nvim-ix. Self-contained: only depends on aibo and
--- cmp-kit, so it can be lifted out on its own.
local Async = require('cmp-kit.kit.Async')
local TriggerContext = require('cmp-kit.core.TriggerContext')

-- "/" at the start of the line or right after whitespace, mirroring
-- aibo's own `find_slash_start` in completion/omnifunc.lua.
local PATTERN = [=[\%(^\|\s\)\zs/\S*]=]

---@param module_name string aibo completion submodule name, e.g. "claude" (aibo.completion.claude)
---@return cmp-kit.completion.CompletionSource
return function(module_name)
  local completion = require('aibo.completion.' .. module_name)

  return {
    name = 'aibo-slash:' .. module_name,
    get_configuration = function()
      return {
        trigger_characters = { '/' },
        keyword_pattern = PATTERN,
      }
    end,
    complete = function(_, _, callback)
      Async.run(function()
        local ctx = TriggerContext.create()
        local off = ctx:get_keyword_offset(PATTERN)
        if not off then
          return { isIncomplete = false, items = {} }
        end

        local query = ctx.text_before:sub(off):lower()
        local items = {}
        for _, item in ipairs(completion.get_commands()) do
          if item.cmd:lower():find(query, 1, true) == 1 then
            table.insert(items, {
              label = item.cmd,
              filterText = item.cmd,
              kind = vim.lsp.protocol.CompletionItemKind.Function,
              labelDetails = item.description ~= '' and { description = item.description } or nil,
              textEdit = {
                newText = item.cmd,
                range = {
                  start = { line = ctx.line, character = off - 1 },
                  ['end'] = { line = ctx.line, character = ctx.character },
                },
              },
            })
          end
        end
        return { isIncomplete = false, items = items }
      end):dispatch(function(res)
        callback(nil, res)
      end, function(err)
        callback(err, nil)
      end)
    end,
  }
end
