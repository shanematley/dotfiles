" Don't re-indent lines on right-angle-bracket or enter
setlocal indentkeys-=<>>
setlocal indentkeys-=<Return>
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2
let b:undo_ftplugin .= '|setlocal indentkeys<'
let b:undo_ftplugin .= '|setlocal tabstop<'
let b:undo_ftplugin .= '|setlocal softtabstop<'
let b:undo_ftplugin .= '|setlocal shiftwidth<'
