" Output long VIM commands in a more raedable format. E.g.
" :Bufferize digraphs or :Bufferize maps or :Bufferize let g:

command! -nargs=* -complete=command Bufferize call s:Bufferize(<q-args>)

function! s:Bufferize(cmd)
    let cmd = a:cmd
    redir => output
    silent exe cmd
    redir END

    new
    setlocal nonumber
    call setline(1, split(output, "\n"))
    set nomodified
endfunction

