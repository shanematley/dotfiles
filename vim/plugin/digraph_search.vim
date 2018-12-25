"
" digraph_search.vim: Insert mode mappings to find a digraph by searching for
" its name in the contents of :help digraph-table.
"
" Author: Tom Ryder <tom@sanctum.geek.nz>
" License: Same as Vim itself
"
if exists('g:loaded_digraph_search') || &compatible
  finish
endif
if !has('digraphs') || v:version < 700
  finish
endif
let g:loaded_digraph_search = 1

" Set up mapping
inoremap <silent> <unique>
      \ <Plug>(DigraphSearch)
      \ <C-O>:call digraph_search#Search()<CR>
