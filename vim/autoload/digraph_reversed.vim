" Insert digraphs by typing the letters then mapped key rather than the normal
" way of entering diagraph mode with C-k and typing the two keys.
function! digraph_reversed#ReplaceWithDigraph()
    let col = col('.')
    let chars = getline('.')[col - 2 : col - 1]
    exe "normal! s\<esc>s\<c-k>".chars
endfunction

