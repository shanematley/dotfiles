function! s:ViewASM(file, gccargs)
    let g:clam_winpos = 'vertical botright'
    let buffer_name = "[view-asm]"
    let winnr = bufwinnr('^' . escape(buffer_name, "[]*+.") . '$')
    if winnr < 0
        silent! execute 'vertical botright new ' . buffer_name
        setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap nonumber
        silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
    else
        silent! execute winnr . 'wincmd w'
    endif
    normal! ggdG
    let l:gcc=sort(glob(exepath("g++") . "*", 1, 1))[-1]
    exe 'r !' . l:gcc .' -Ofast -std=c++1y -fno-stack-protector -masm=intel -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm -fomit-frame-pointer -mtune=native -march=native -fverbose-asm ' . a:gccargs . ' -S -o - -c '. a:file . '| sed -e "/^\t\\.[a-z0-9]*[^:]/d" -e "/^\\.L[^0-9][A-Z0-9]*:$/d"  | c++filt'
    set ft=gas
    " set readonly
    " set nomodified
    goto 1
endfunction
command! -nargs=* ViewASM call s:ViewASM(expand('%'), <q-args>)
