let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'gitbranch', 'filename'], [ 'cocstatus', 'readonly' ] ],
      \   'right': [ ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'tabline': {
      \   'left': [ [ 'tabs' ] ], 'right': [ [ 'close'] ],
      \ },
      \ 'tab': {
      \   'active': [ 'tabnum', 'filename', 'modified' ],
      \   'inactive': [ 'tabnum', 'filename', 'modified' ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'StatusFugitive',
      \   'filename': 'StatusFileName',
      \   'gitbranch': 'FugitiveHead',
      \   'mode': 'StatusFileMode',
      \   'cocstatus': 'coc#status',
      \ }
      \ }
let g:lightline.enable = { 'statusline': 1, 'tabline': 1 }

function! s:StatusModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! s:StatusReadonly()
  return &ft !~? 'help' && &readonly ? "\ue0a2" : ''
endfunction

function! StatusFileName()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ ('' != s:StatusReadonly() ? s:StatusReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != s:StatusModified() ? ' ' . s:StatusModified() : '')
endfunction

function! StatusFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD' && &ft !~? 'vimfiler' && exists('*fugitive#head')
      let mark = "\ue0a0 "  " edit here for cool mark
      let _ = fugitive#head()
      return strlen(_) ? mark._ : ''
    endif
  catch
  endtry
  return ''
endfunction

function! StatusFileMode()
  let fname = expand('%:t')
  return fname == '__Tagbar__' ? 'Tagbar' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' : lightline#mode()
endfunction

