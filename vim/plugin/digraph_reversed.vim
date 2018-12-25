if exists('g:loaded_digraph_reversed') || &compatible
  finish
endif
if !has('digraphs') || v:version < 700
  finish
endif
let g:loaded_digraph_reversed = 1

inoremap <silent>
    \ <Plug>(DigraphFromPrevChars)
    \ <esc>:call digraph_reversed#ReplaceWithDigraph()<cr>a
