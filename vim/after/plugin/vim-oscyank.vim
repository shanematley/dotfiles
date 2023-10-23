
if exists("OSCYankRegister")
    autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | execute 'OSCYankRegister +' | endif
endif
vmap <leader>c <Plug>OSCYankVisual

