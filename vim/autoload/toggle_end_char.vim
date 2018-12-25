" Toggles a charater at the end, used below for <leader>; to toggle end semi-colon
function! toggle_end_char#ToggleEndChar(charToMatch)
    exec "norm! m`"
    s/\v(.)$/\=submatch(1)==a:charToMatch ? '' : submatch(1).a:charToMatch
    exec "norm! ``"
endfunction

