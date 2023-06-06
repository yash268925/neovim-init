call ddu#custom#alias('column', 'icon_filename_for_ff', 'icon_filename')
call ddu#custom#patch_global({
  \   'ui': 'ff',
  \   'sources': [
  \     {
  \       'name': 'file_rec',
  \       'params': {
  \         'ignoredDirectories': ['.git', 'node_modules', 'vendor']
  \       },
  \     },
  \   ],
  \   'columns': ['icon_filename'],
  \   'sourceOptions': {
  \     '_': {
  \       'matchers': ['matcher_hidden', 'matcher_fzf'],
  \     },
  \     'file_rec': {
  \       'columns': ['icon_filename_for_ff'],
  \     },
  \   },
  \   'kindOptions': {
  \     'file': {
  \       'defaultAction': 'open',
  \     },
  \   },
  \   'uiParams': {
  \     'ff': {
  \       'split': 'floating',
  \       'floatingBorder': 'single',
  \       'filterFloatingPosition': 'top',
  \       'autoAction': {
  \         'name': 'preview',
  \       },
  \       'previewFloating': v:true,
  \       'previewFloatingBorder': 'single',
  \       'previewSplit': 'vertical',
  \       'startFilter': v:true,
  \       'prompt': '> ',
  \       'winHeight': floor(&lines * 0.8),
  \       'winRow': floor(&lines * 0.1),
  \       'winWidth': floor(&columns * 0.8),
  \       'winCol': floor(&columns * 0.1),
  \       'previewWidth': floor(&columns * 0.8 / 2),
  \     },
  \   },
  \   'filterParams': {
  \     'matcher_fzf': {
  \       'highlightMatched': 'Search',
  \     },
  \   },
  \   'columnParams': {
  \     'icon_filename_for_ff': {
  \       'defaultIcon': {
  \         'icon': '',
  \       },
  \       'padding': 0,
  \       'pathDisplayOption': 'relative',
  \     },
  \   },
  \ })

call ddu#custom#patch_local('rg', {
  \   'sourceParams': {
  \     'rg': {
  \       'args': ['--column', '--no-heading', '--color', 'never', '--json'],
  \     },
  \   },
  \   'uiParams': {
  \     'ff': {
  \       'startFilter': v:false,
  \     },
  \   },
  \ })

call ddu#custom#patch_local('buffer', {
  \   'uiParams': {
  \     'ff': {
  \       'startFilter': v:false,
  \     },
  \   },
  \ })

autocmd TabEnter,CursorHold,FocusGained <buffer>
	\ call ddu#ui#do_action('checkItems')

autocmd FileType ddu-ff call s:ddu_ff_my_settings()

function! s:ddu_ff_my_settings() abort
  nnoremap <buffer><silent> <Enter>
    \ <Cmd>call ddu#ui#do_action('itemAction', {'name': 'open'})<CR>

  nnoremap <buffer><silent> <Esc>
    \ <Cmd>call ddu#ui#do_action('quit')<CR>

  nnoremap <buffer><silent> f
    \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>

  nnoremap <buffer><silent> d
    \ <Cmd>call ddu#ui#do_action('itemAction', { 'name': 'delete' })<CR>

  nnoremap <buffer><silent> .
    \ <Cmd>call ddu#ui#do_action('updateOptions', {
    \   'sourceOptions': {
    \     '_': {
    \       'matchers': ToggleHidden(),
    \     },
    \   },
    \ })<CR>

  function! ToggleHidden()
    let current = ddu#custom#get_current(b:ddu_ui_name)
    let source_options = get(current, 'sourceOptions', {})
    let source_options_all = get(source_options, '_', {})
    let matchers = get(source_options_all, 'matchers', {})
    if index(matchers, 'matcher_hidden') >= 0
      call remove(matchers, 'matcher_hidden')
    else
      call add(matchers, 'matcher_hidden')
    endif
    return matchers
  endfunction
endfunction

autocmd FileType ddu-ff-filter call s:ddu_ff_filter_my_settings()

function! s:ddu_ff_filter_my_settings() abort
  inoremap <buffer><silent> <Enter>
    \ <Esc><Cmd>call ddu#ui#do_action('leaveFilterWindow')<CR>
endfunction

nmap <silent> ;f <Cmd>call ddu#start({})<CR>

nmap <silent> ;r <Cmd>call ddu#start({
  \   'name': 'rg',
  \   'sources': [
  \     {
  \       'name': 'rg',
  \       'params': {
  \         'input': expand('<cword>'),
  \       },
  \     },
  \   ],
  \ })<CR>

nmap <silent> ;b <Cmd>call ddu#start({
  \   'name': 'buffer',
  \   'sources': [
  \     {
  \       'name': 'buffer',
  \     },
  \   ],
  \ })<CR>
