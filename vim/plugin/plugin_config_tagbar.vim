autocmd FileType tagbar nnoremap <buffer> <silent> <ESC> <ESC>:TagbarClose<CR>
let g:tagbar_status_func = 'TagbarStatusFunc'
let g:tagbar_type_rst = {
    \ 'ctagstype': 'rst',
    \ 'ctagsbin' : '/usr/bin/rst2ctags',
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

function! TagbarStatusFunc(current, sort, fname, ...) abort
    let g:lightline.fname = a:fname
  return lightline#statusline(0)
endfunction

nnoremap <silent> <leader>d :TagbarOpenAutoClose<CR>
