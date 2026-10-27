local specs = require('dotvim._lib.specs')
local utils = require('dotvim._lib.utils')

-- 他の機能が completion の setup より前に登録できるよう、トップレベルに置く
---@type (fun(bufnr: integer): boolean)[]
local attachers = {}

local function set_highlights()
  utils.hl_link({
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
end

---@class dotvim.completion: dotvim.Feature
local M = require('dotvim._lib.feature').define({
  name = 'completion',
  specs = {
    specs.mini_icons,
    { src = 'https://github.com/hrsh7th/nvim-cmp-kit' },
    { src = 'https://github.com/hrsh7th/nvim-ix' },
  },
  setup = function()
    local group = vim.api.nvim_create_augroup('dotvim.completion', { clear = true })

    set_highlights()
    -- :colorscheme はハイライトを初期化するため、後から読み込まれても消えないように再適用する
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = group,
      callback = set_highlights,
    })

    local kinds = require('cmp-kit.kit.LSP').CompletionItemKind
    local kinds_lookup = {}

    local icons = require('dotvim._lib.mini').icons()

    for k, v in pairs(kinds) do
      local kind = k
      local icon, hl = icons.get('lsp', kind:lower())

      icon = icon .. ' '

      kinds_lookup[v] = { icon, hl }
    end


    local ix = require('ix')

    local default_insert_mode = ix.get_default_config().attach.insert_mode

    ix.setup({
      expand_snippet = function(body) vim.snippet.expand(body) end,
      completion = {
        icon_resolver = function(kind)
          return kinds_lookup[kind] or { '', '' }
        end,
      },
      attach = {
        insert_mode = function()
          local bufnr = vim.api.nvim_get_current_buf()
          for _, attach in ipairs(attachers) do
            if attach(bufnr) then
              return
            end
          end
          default_insert_mode()
        end,
      },
    })

    local keymaps = utils.keymaps

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
  end,
})

M._attachers = attachers

---挿入モードに入ったバッファの補完ソースを差し替える関数を登録する。
---fn が true を返すと、既定のソース (LSP / buffer / path など) を登録しない。
---@param fn fun(bufnr: integer): boolean
function M.register_attacher(fn)
  table.insert(attachers, fn)
end

return M
