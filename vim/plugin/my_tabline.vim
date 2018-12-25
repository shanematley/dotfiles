if exists('g:loaded_my_tabline') || &compatible
  finish
endif
if !exists('+showtabline')
  finish
endif
let g:loaded_my_tabline = 1

set tabline=%!my_tabline#MyTabLine()
