" vaffle.vim
let g:vaffle_render_custom_icon = 'VaffleRenderCustomIcon'
let NERDTreeHijackNetrw = 0

function! VaffleRenderCustomIcon(item)
  return WebDevIconsGetFileTypeSymbol(a:item.basename, a:item.is_dir)
endfunction

function! s:open_vaffle()
  let s:path = expand("%:h")
  if isdirectory(s:path)
    call vaffle#init(s:path)
  else
    call vaffle#init()
  endif
endfunction

command! CVaffle call s:open_vaffle()

nnoremap to :<C-u>CVaffle<CR>


" vim-oscyank
let g:oscyank_term = 'kitty'
let g:clipboard = {
  \ 'name': 'osc52',
  \ 'copy': {
  \   '+': {lines, regtype -> OSCYank(join(lines, "\n"))},
  \   '*': {lines, regtype -> OSCYank(join(lines, "\n"))},
  \ },
  \ 'paste': {
  \   '+': {-> [split(getreg(''), '\n'), getregtype('')]},
  \   '*': {-> [split(getreg(''), '\n'), getregtype('')]},
  \ },
  \ }


" vim-toggle-quickfix
nmap <C-q><C-l> <Plug>window:quickfix:loop


" gin.vim
let g:gin_log_default_args = ['--graph', '--oneline', '--decorate=full', '--date-order', '--all']


" suda.vim
let g:suda_smart_edit = 1


" pum.vim
inoremap <silent><expr> <TAB>
    \ pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' :
    \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
    \ '<TAB>' : ddc#manual_complete()

inoremap <S-Tab>    <Cmd>call pum#map#insert_relative(-1)<CR>
inoremap <C-n>      <Cmd>call pum#map#insert_relative(+1)<CR>
inoremap <C-p>      <Cmd>call pum#map#insert_relative(-1)<CR>
inoremap <C-y>      <Cmd>call pum#map#confirm()<CR>
inoremap <C-e>      <Cmd>call pum#map#cancel()<CR>

" denops-popup-preview.vim
call popup_preview#enable()

set foldexpr=nvim_treesitter#foldexpr()
