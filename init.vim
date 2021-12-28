" dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

set runtimepath+=$HOME/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state($HOME . '/.config/nvim/dein')

  let g:dein#cache_directory = $HOME . '/.cache/dein'

  call dein#begin($HOME . '/.cache/dein')

  let s:toml_dir         = $HOME . '/.config/nvim/toml' 
  let s:toml             = s:toml_dir . '/dein.toml'
  let s:lazy_toml        = s:toml_dir . '/dein_lazy.toml'
  let s:lazy_lsp         = s:toml_dir . '/dein_lsp.toml'

  call dein#load_toml(s:toml,             {'lazy': 0})
  call dein#load_toml(s:lazy_toml,        {'lazy': 1})
  call dein#load_toml(s:lazy_lsp,         {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

"if dein#check_install()
"  call dein#install()
"endif

" End dein Scripts-------------------------

" load project local vimrc----------------
augroup vimrc-local
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:vimrc_local(expand('<afile>:p:h'))
augroup END

function! s:vimrc_local(loc)
  let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
  for i in reverse(filter(files, 'filereadable(v:val)'))
    source `=i`
  endfor
endfunction

" End load project local vimrc------------


" load subscript--------------------------
function! s:load_subscript(name)
  let file = expand('~/.config/nvim/' . a:name)
  if filereadable(file)
    source `=file`
  endif
endfunction

call s:load_subscript('defaults.vim')
call s:load_subscript('functions.vim')

" End load subscript----------------------
