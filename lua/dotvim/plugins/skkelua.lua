vim.pack.add({
  { src = 'https://github.com/kjuq/skkelua.nvim', version = 'master' },
})

require('skkelua').config({
  eggLikeNewline = true,
  immediatelyDictionaryRW = true,
  registerConvertResult = true,
  setUndoPoint = true,
  globalDictionaries = {
    '~/.local/share/skk/SKK-JISYO.L',
    '~/.local/share/skk/SKK-JISYO.emoji-ja.utf8',
    '~/.local/share/skk/SKK-JISYO.emoji.utf8',
  },
  userDictionary = '~/.local/share/skk/skk-jisyo.utf8',
})

-- 辞書ロードは同期で数百 ms かかり、未初期化だと初回の有効化時に待たされる。
-- 起動中に読むと起動が遅れるので、UI の描画を終えた後に読み込んでおく。
vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    vim.defer_fn(function()
      require('skkelua').initialize()
    end, 100)
  end,
})

local keymaps = require('dotvim._lib.utils').keymaps

keymaps({
  { { 'i', 'c', 't' }, '<M-j>', '<Plug>(skkelua-toggle)' },
})
