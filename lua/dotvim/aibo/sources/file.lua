--- cmp-kit CompletionSource for nvim-aibo's "@" file-path completion.
--- Delegates path parsing/listing to `aibo.completion.file` (the same module
--- aibo's own omnifunc uses), so root/segment/drill-down behavior is
--- identical either way -- this file only adapts its results to LSP
--- completion items for nvim-ix. Self-contained: only depends on aibo and
--- cmp-kit, so it can be lifted out on its own.
local Async = require('cmp-kit.kit.Async')
local TriggerContext = require('cmp-kit.core.TriggerContext')
local file_completion = require('aibo.completion.file')

local KIND = {
  File = vim.lsp.protocol.CompletionItemKind.File,
  Dir = vim.lsp.protocol.CompletionItemKind.Folder,
}

---@return cmp-kit.completion.CompletionSource
return function()
  return {
    name = 'aibo-file',
    get_configuration = function()
      return {
        -- "/" must stay a trigger character too: descending into a
        -- directory needs a fresh listing, not a client-side narrowing of
        -- the previous one.
        trigger_characters = { '@', '/' },
        keyword_pattern = [=[@\S*]=],
      }
    end,
    complete = function(_, _, callback)
      Async.run(function()
        local ctx = TriggerContext.create()
        local col = ctx.character + 1 -- 1-indexed, like vim.fn.col('.')
        local at_start = file_completion.find_at_start(ctx.text, col)
        if not at_start then
          return { isIncomplete = false, items = {} }
        end

        local base = ctx.text:sub(at_start, col - 1)
        local items = {}
        for _, entry in ipairs(file_completion.get_completions(base)) do
          -- `entry.word` never has a trailing "/" even for directories
          -- (aibo's own convention, see completion/file.lua) -- typing "/"
          -- manually re-triggers this source for the next segment.
          table.insert(items, {
            label = entry.abbr or entry.word,
            filterText = entry.word,
            kind = KIND[entry.kind],
            labelDetails = entry.menu ~= '' and { description = entry.menu } or nil,
            textEdit = {
              newText = entry.word,
              range = {
                start = { line = ctx.line, character = at_start - 1 },
                ['end'] = { line = ctx.line, character = ctx.character },
              },
            },
          })
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
