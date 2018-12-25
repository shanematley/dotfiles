let g:lightline = {
      \ 'colorscheme': 'Dracula',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ], ['ctrlpmark', 'agsstats'] ],
      \   'right': [ [ 'syntastic', 'lineinfo' ], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'StatusFugitive',
      \   'filename': 'StatusFileName',
      \   'mode': 'StatusFileMode',
      \   'ctrlpmark': 'StatusCtrlPMark',
      \   'agsstats': 'StatusAgsStats',
      \ },
      \ 'component_expand': {
      \   'syntastic': 'SyntasticStatuslineFlag',
      \ },
      \ 'component_type': {
      \   'syntastic': 'error',
      \ },
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" }
      \ }
let g:lightline.enable = { 'statusline': 1, 'tabline': 0 }

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
        \ fname == 'search-results.agsv' ? split(ags#get_status_string())[2] :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ ('' != s:StatusReadonly() ? s:StatusReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != s:StatusModified() ? ' ' . s:StatusModified() : '')
endfunction

function! StatusFugitive()
  try
    if expand('%:t') !~? 'Tagbar\|Gundo\|NERD\|search-results.agsv' && &ft !~? 'vimfiler' && exists('*fugitive#head')
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
        \ fname == 'ControlP' ? 'CtrlP' :
        \ fname == '__Gundo__' ? 'Gundo' :
        \ fname == 'search-results.agsv' ? 'AgS' :
        \ fname == '__Gundo_Preview__' ? 'Gundo Preview' :
        \ fname =~ 'NERD_tree' ? 'NERDTree' : lightline#mode()
endfunction

function! StatusCtrlPMark()
  if expand('%:t') =~ 'ControlP'
    call lightline#link('iR'[g:lightline.ctrlp_regex])
    return lightline#concatenate([g:lightline.ctrlp_prev, g:lightline.ctrlp_item
          \ , g:lightline.ctrlp_next], 0)
  else
    return ''
  endif
endfunction

function! StatusAgsStats()
  if expand('%:t') =~ 'search-results.agsv'
    return join(split(ags#get_status_string())[0:1], " " . g:lightline.subseparator.left . " ")
  else
    return ''
  endif
endfunction
