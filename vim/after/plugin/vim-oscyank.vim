
let g:VimOSCYankPostRegisters = ['+', '*']

" In the event that the clipboard isn't working, it's quite likely that
" the + and * registers will not be distinct from the unnamed register. In
" this case, a:event.regname will always be '' (empty string). However, it
" can be the case that `has('clipboard_working')` is false, yet `+` is
" still distinct, so we want to check them all.
"
" Uncomment the below to just always copy to system clipboard if there is no
" clipboard support compiled in.

"if (!has('nvim') && !has('clipboard_working'))
"    let g:VimOSCYankPostRegisters = ['', '+', '*']
"endif

function! s:VimOSCYankPostCallback(event)
    if a:event.operator == 'y' && index(g:VimOSCYankPostRegisters, a:event.regname) != -1
        call OSCYankRegister(a:event.regname)
    endif
endfunction

augroup VimOSCYankPost
    autocmd!
    autocmd TextYankPost * call s:VimOSCYankPostCallback(v:event)
augroup END

nmap <leader>c <Plug>OSCYankOperator
nmap <leader>cc <leader>c_
vmap <leader>c <Plug>OSCYankVisual

