require('dotvim.plugins.denops')

vim.pack.add({
  { src = 'https://github.com/vim-skk/skkeleton' },
})

vim.fn['skkeleton#config']({
  eggLikeNewline = true,
  immediatelyDictionaryRW = true,
  registerConvertResult = true,
  globalDictionaries = {
    '~/.local/share/skk/SKK-JISYO.L',
    '~/.local/share/skk/SKK-JISYO.emoji-ja.utf8',
    '~/.local/share/skk/SKK-JISYO.emoji.utf8',
  },
  userDictionary = '~/.local/share/skk/skk-jisyo.utf8',
})

local keymaps = require('dotvim.utils').keymaps

keymaps({
  { { 'i', 'c', 't' }, '<M-j>', '<Plug>(skkeleton-toggle)' },
})
