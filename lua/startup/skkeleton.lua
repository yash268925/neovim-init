local split = require('lib').split

vim.fn['skkeleton#config'] {
  eggLikeNewline = true,
  globalDictionaries = split(vim.fn.expand('~/.skk/dict/*'), '\n'),
  immediatelyDictionaryRW = true,
  registerConvertResult = true,
  userDictionary = '~/.skk/userJisyo',
}

local switchKey = vim.g['skkeleton#switch_key']

if not switchKey then
  switchKey = '<C-j>'
end

vim.keymap.set('i', switchKey, '<Plug>(skkeleton-toggle)')
vim.keymap.set('c', switchKey, '<Plug>(skkeleton-toggle)')
vim.keymap.set('t', switchKey, '<Plug>(skkeleton-toggle)')

vim.cmd([[
  hi SkkeletonIndicatorEiji guifg=#88c0d0 guibg=#2e3440 gui=bold
  hi SkkeletonIndicatorHira guifg=#2e3440 guibg=#a3be8c gui=bold
  hi SkkeletonIndicatorKata guifg=#2e3440 guibg=#ebcb8b gui=bold
  hi SkkeletonIndicatorHankata guifg=#2e3440 guibg=#b48ead gui=bold
  hi SkkeletonIndicatorZenkaku guifg=#2e3440 guibg=#88c0d0 gui=bold
]])

require('skkeleton_indicator').setup {
  alwaysShown = true,
  fadeOutMs = 0,
}
