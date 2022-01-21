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

  call dein#end()

  lua require('impatient')

  call dein#save_state()
endif

filetype plugin indent on
syntax enable
