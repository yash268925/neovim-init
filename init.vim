function! LoadSubscript(name)
  let file = expand('~/.config/nvim/' . a:name)
  if filereadable(file)
    source `=file`
  endif
endfunction

call LoadSubscript('defaults.vim')
call LoadSubscript('functions.vim')
call LoadSubscript('plugins.vim')

colorscheme iceberg
