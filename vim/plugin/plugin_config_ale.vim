
" Disable by default
let g:ale_enabled = 0

" Prefer use of COC
let g:ale_disable_lsp = 1

let g:ale_linters = {
    \ 'python': ['flake8', 'bandit', 'pyls']}

let g:ale_python_pylsp_executable = 'pyls'

let g:ale_fixers = {
    \   'cpp': ['clang-format'],
    \   'python': ['black', 'isort'],
    \   'starlark': ['buildifier'],
    \   'bzl': ['buildifier'],
    \}

