if &compatible
  set nocompatible               " Be iMproved
endif

set runtimepath+=$HOME/.local/share/dein/repos/github.com/Shougo/dein.vim

if dein#load_state($HOME . '/.config/nvim/dein')

  call dein#begin(expand('~/.local/share/dein'))

  let s:toml_dir         = $HOME . '/.config/nvim/toml' 
  let s:toml             = s:toml_dir . '/dein.toml'
  let s:lazy_toml        = s:toml_dir . '/dein_lazy.toml'

  call dein#load_toml(s:toml,             {'lazy': 0})
  call dein#load_toml(s:lazy_toml,        {'lazy': 1})

  call dein#end()

  call dein#save_state()
endif

lua require('impatient')
lua require('init/lspconfig')
lua require('init/treesitter')

call LoadSubscript('init/plugin.vim')
call LoadSubscript('init/ddc.vim')
call LoadSubscript('init/ddu.vim')

set foldexpr=nvim_treesitter#foldexpr()
