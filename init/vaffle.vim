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
