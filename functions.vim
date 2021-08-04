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
