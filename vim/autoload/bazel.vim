" From https://gitlab.trading.imc.intra/-/snippets/1106

function! s:BazelIncludeExpr(fname)
  let [_, _, pkg, _, path, name] = matchlist(a:fname, '\(@\([^/]\+\)\)\?\(//\([^:]*\)\)\?:\?\(.*\)')[0:5]
  "                                          example: ...@......pkg.......//.....path....:...name..
  let possible_paths = [
          \ name,
          \ path . '/' . name,
          \ path . '/BUILD.bazel',
          \ path . '/BUILD',
          \ g:bazel_info['execution_root'] . '/external/' . pkg . '/' . path . '/' . name,
          \ g:bazel_info['execution_root'] . '/external/' . pkg . '/' . path . '/BUILD.bazel',
          \ g:bazel_info['execution_root'] . '/external/' . pkg . '/' . path . '/BUILD',
          \ g:bazel_info['output_base'] . '/external/' . pkg . '/' . path . '/' . name,
          \ g:bazel_info['output_base'] . '/external/' . pkg . '/' . path . '/BUILD.bazel',
          \ g:bazel_info['output_base'] . '/external/' . pkg . '/' . path . '/BUILD',
          \ ]
  return possible_paths->filter({_, ppath -> len(findfile(ppath))})->get(0, name)
endfunction

function! BazelInfo()
  let g:bazel_info={}
  function! s:handler(channel, msg)
    let [k, v] = a:msg->split(':\s\+')
    let g:bazel_info[k] = v
  endfunction
  call jobstart('bazel info', {
        \ "mode": "nl",
        \ "out_cb": "s:handler",
        \ })
endf
call BazelInfo()

augroup bazel
  autocmd!
  autocmd FileType starlark,bzl setlocal
        \ includeexpr=s:BazelIncludeExpr(v:fname)
        \ isfname+=:,@-@
  autocmd FileType starlark,bzl let &l:include='load("\zs[^"]\+\ze"'
  autocmd FileType starlark,bzl let &l:define='\(^\s*\(def\|class\)\|\s*\ze[^ ]\+\s*=\s*\(repository_\)\?rule(\)'
augroup END


