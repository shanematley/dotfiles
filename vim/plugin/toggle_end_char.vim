if exists('g:toggle_end_char') || &compatible
  finish
endif
let g:toggle_end_char = 1

nnoremap <Plug>(ToggleSemicolonAtEnd) :call toggle_end_char#ToggleEndChar(';')<CR>

