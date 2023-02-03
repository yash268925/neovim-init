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
  \   '+': {lines, regtype -> OSCYankString(join(lines, "\n"))},
  \   '*': {lines, regtype -> OSCYankString(join(lines, "\n"))},
  \ },
  \ 'paste': {
  \   '+': {-> [split(getreg(''), '\n'), getregtype('')]},
  \   '*': {-> [split(getreg(''), '\n'), getregtype('')]},
  \ },
  \ }


" vim-toggle-quickfix
nmap <C-q><C-l> <Plug>window:quickfix:loop


" gin.vim
command GinLogg :GinLog --graph --oneline --decorate=full
command GinLoggAll :GinLog --graph --oneline --decorate=full --all


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


" ddc.vim
call ddc#custom#patch_global('ui', 'pum')

call ddc#custom#patch_global('autoCompleteEvents', [
      \ 'InsertEnter', 'TextChangedI', 'TextChangedP',
      \ 'CmdlineChanged',
      \ ])

nnoremap :       <Cmd>call CommandlinePre()<CR>:

function! CommandlinePre() abort
  cnoremap <Tab>   <Cmd>call pum#map#insert_relative(+1)<CR>
  cnoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
  cnoremap <C-n>   <Cmd>call pum#map#insert_relative(+1)<CR>
  cnoremap <C-p>   <Cmd>call pum#map#insert_relative(-1)<CR>
  cnoremap <C-y>   <Cmd>call pum#map#confirm()<CR>
  cnoremap <C-e>   <Cmd>call pum#map#cancel()<CR>

  " Overwrite sources
  if !exists('b:prev_buffer_config')
    let b:prev_buffer_config = ddc#custom#get_buffer()
  endif
  call ddc#custom#patch_buffer('cmdlineSources',
         \ ['cmdline', 'cmdline-history', 'path'])

  autocmd User DDCCmdlineLeave ++once call CommandlinePost()
  autocmd InsertEnter <buffer> ++once call CommandlinePost()

  " Enable command line completion
  call ddc#enable_cmdline_completion()
endfunction

function! CommandlinePost() abort
  silent! cunmap <Tab>
  silent! cunmap <S-Tab>
  silent! cunmap <C-n>
  silent! cunmap <C-p>
  silent! cunmap <C-y>
  silent! cunmap <C-e>

  " Restore sources
  if exists('b:prev_buffer_config')
    call ddc#custom#set_buffer(b:prev_buffer_config)
    unlet b:prev_buffer_config
  else
    call ddc#custom#set_buffer({})
  endif
endfunction


call ddc#custom#patch_global('sources', [
  \ 'nvim-lsp',
  \ 'rg',
  \ 'file',
  \ ])

call ddc#custom#patch_global('cmdlineSources', [
  \ 'cmdline',
  \ 'cmdline-history',
  \ 'path',
  \ ])

call ddc#custom#patch_global('sourceOptions', {
  \ '_': {
  \   'ignoreCase': v:true,
  \   'maxItems': 20,
  \   'minAutoCompleteLength': 1,
  \   'matchers': ['matcher_fuzzy'],
  \   'sorters': ['sorter_fuzzy'],
  \   'converters': ['converter_fuzzy'],
  \ },
  \ 'skkeleton': {
  \   'mark': 'skkeleton',
  \   'matchers': ['skkeleton'],
  \   'sorters': [],
  \   'minAutoCompleteLength': 2,
  \   'isVolatile': v:true,
  \ },
  \ 'suconv': {
  \   'mark': 'skk-suconv',
  \   'converters': [],
  \   'matchers': [],
  \   'sorters': [],
  \   'isVolatile': v:true,
  \ },
  \ 'path': {
  \   'mark': 'P',
  \ },
  \ 'file': {
  \   'mark': 'F',
  \   'isVolatile': v:true,
  \   'forceCompletionPattern': '\S/\S*',
  \ },
  \ 'nvim-lsp': {
  \   'mark': 'LSP',
  \   'forceCompletionPattern': '\.\w*|:\w*|->\w*',
  \ },
  \ 'cmdline': {
  \   'mark': 'vimcmd',
  \ },
  \ 'cmdline-history': {
  \   'mark': 'history',
  \ },
  \ 'rg': {
  \   'mark': 'rg',
  \   'minAutoCompleteLength': 4,
  \ },
  \ })

call ddc#custom#patch_global('sourceParams', {
  \ 'file':     {
  \   'smartCase': v:true,
  \ },
  \ 'path': {
  \   'cmd': ['fd', '--max-depth', '5'],
  \   'absolute': v:false,
  \ },
  \ })

autocmd CompleteDone * silent! pclose!

autocmd User skkeleton-enable-pre call s:skkeleton_pre()
function! s:skkeleton_pre() abort
  " Overwrite sources
  let s:prev_buffer_config = ddc#custom#get_buffer()
  call ddc#custom#patch_buffer('sources', ['skkeleton'])
endfunction

autocmd User skkeleton-disable-pre call s:skkeleton_post()
function! s:skkeleton_post() abort
  " Restore sources
  call ddc#custom#set_buffer(s:prev_buffer_config)
endfunction

call ddc#enable()


" denops-popup-preview.vim
call popup_preview#enable()