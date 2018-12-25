if &filetype !=# 'cpp' || v:version < 700
    finish
endif

nnoremap <buffer> gR :.ClangFormat<CR>
vnoremap <buffer> gR :ClangFormat<CR>

" include macros in completion
setlocal complete+=d

" set include pattern
setlocal include=^\\s*#\\s*include

" include headers on UNIX
if has('unix')
    setlocal path+=/usr/include

    " gcc 8.2 on Homebrew
    if isdirectory('/usr/local/include/c++/8.2.0/')
        setlocal path+=/usr/local/include/c++/8.2.0/
    endif
endif

let b:undo_ftplugin .= '|setlocal complete< include< path<'
