local hl_link = require('dotvim.utils').hl_link

hl_link({
  CmpKitMarkdownAnnotateUnderlined = 'Special',
  CmpKitMarkdownAnnotateBold = 'Special',
  CmpKitMarkdownAnnotateEm = 'Special',
  CmpKitMarkdownAnnotateStrong = 'Visual',
  CmpKitMarkdownAnnotateCodeBlock = 'CursorColumn',
  CmpKitMarkdownAnnotateHeading1 = 'Title',
  CmpKitMarkdownAnnotateHeading2 = 'Title',
  CmpKitMarkdownAnnotateHeading3 = 'Title',
  CmpKitMarkdownAnnotateHeading4 = 'Title',
  CmpKitMarkdownAnnotateHeading5 = 'Title',
  CmpKitMarkdownAnnotateHeading6 = 'Title',
  CmpKitDeprecated = 'CmpItemAbbrDeprecated',
  CmpKitCompletionItemLabel = 'CmpItemAbbr',
  CmpKitCompletionItemDescription = 'CmpItemMenu',
  CmpKitCompletionItemMatch = 'CmpItemAbbrMatch',
  CmpKitCompletionItemExtra = 'CmpItemMenu',
})



vim.pack.add({
  { src = 'https://github.com/hrsh7th/nvim-cmp-kit' },
  { src = 'https://github.com/hrsh7th/nvim-ix' },
})

local kinds = require('cmp-kit.kit.LSP').CompletionItemKind
local kinds_lookup = {}

local icons = require('dotvim.plugins.mini').icons

for k, v in pairs(kinds) do
  local kind = k
  local icon, hl = icons.get('lsp', kind:lower())

  icon = icon .. ' '

  kinds_lookup[v] = { icon, hl }
end


local ix = require('ix')

ix.setup({
  expand_snippet = function(body) vim.snippet.expand(body) end,
  completion = {
    icon_resolver = function(kind)
      return kinds_lookup[kind] or { '', '' }
    end,
  }
})

local keymaps = require('dotvim.utils').keymaps

keymaps({
  { { 'i', 'c', 's' }, '<C-d>',     ix.action.scroll(0 + 3) },
  { { 'i', 'c', 's' }, '<C-u>',     ix.action.scroll(0 - 3) },

  { { 'i', 'c' },      '<C-Space>', ix.action.completion.complete() },
  { { 'i', 'c' },      '<C-n>',     ix.action.completion.select_next() },
  { { 'i', 'c' },      '<C-p>',     ix.action.completion.select_prev() },
  { { 'i', 'c' },      '<C-e>',     ix.action.completion.close() },
})

ix.charmap.set('c', '<CR>', ix.action.completion.commit_cmdline())
ix.charmap.set('i', '<CR>', ix.action.completion.commit({ select_first = true }))
