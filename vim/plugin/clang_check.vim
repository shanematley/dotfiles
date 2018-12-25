if exists('g:loaded_clang_check') || &compatible
  finish
endif
let g:loaded_clang_check = 1

nmap <Plug>(RunClangCheck) :call clang_check#ClangCheck()<CR><CR>

