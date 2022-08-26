let s:replaceEntity = [
\  ['\(\(&\(#*\w\+;\)\@!\)\|&amp;\|&#38;\)', '\&#x26;'],
\  ['\(\"\|&quot;\|&#34;\)',                 '\&#x22;'],
\  ["\\('\\|&#39;\\)",                       '\&#x27;'],
\  ['\(<\|&lt;\|&#60;\)',                    '\&#x3C;'],
\  ['\(>\|&gt;\|&#62;\)',                    '\&#x3E;'],
\]

function! s:htmlesc() range
  for l:line in range(a:firstline, a:lastline)
    let l:_line = getline(l:line)
    for l:replace in s:replaceEntity
      let l:_line = substitute(l:_line, l:replace[0], l:replace[1], 'g')
    endfor
    call setline(l:line, l:_line)
  endfor
endfunction

command! -range HtmlEsc <line1>, <line2> call s:htmlesc()

command -bar -nargs=? -complete=help HelpCurwin execute s:HelpCurwin(<q-args>)
let s:did_open_help = v:false

function s:HelpCurwin(subject) abort
  let mods = 'silent noautocmd keepalt'
  if !s:did_open_help
    execute mods .. ' help'
    execute mods .. ' helpclose'
    let s:did_open_help = v:true
  endif
  if !empty(getcompletion(a:subject, 'help'))
    execute mods .. ' edit ' .. &helpfile
    set buftype=help
  endif
  return 'help ' .. a:subject
endfunction
