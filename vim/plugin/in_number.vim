if exists('g:loaded_in_number') || &compatible
  finish
endif
let g:loaded_in_number = 1

" "in number" (next number after cursor on current line)
xnoremap <silent> <Plug>(XInNumber) :<c-u>call in_number#inNumber()<cr>
onoremap <silent> <Plug>(OInNumber) :<c-u>call in_number#inNumber()<cr>

" "around number" (next number on line and possible surrounding white-space)
xnoremap <silent> <Plug>(XAroundNumber) :<c-u>call in_number#aroundNumber()<cr>
onoremap <silent> <Plug>(OAroundNumber) :<c-u>call in_number#aroundNumber()<cr>

