" Extensibility points
" There is one file specifically looked for in b:local_vim_files:
" * ycmconf.py      -- Configuration for YouCompleteMe. (Also requires the
"                      YouCompleteMe plugin to be added in the first place
"                      by adding the bundle to vundle.vimrc)
"
" Additionally ~/.vimrc.local is loaded at some point for local config.

let b:local_vim_files = "~/.vim/local/"

let mapleader = ","
:nmap <space> ,

" General ---------------------------------------------------------------------- {{{
set history=1000
set nocompatible
" Enable mouse mode. Use SGR 1006 mouse mode if the functionality is present
" in this version of VIM. This was added in 7.3.632 and must be compiled in.
set mouse=a
if has("mouse_sgr")
    set ttymouse=sgr
else
    set ttymouse=xterm2
endif
"}}}

" Searching -------------------------------------------------------------------- {{{

" Turn off default regex handling and use normal regexes, i.e. use 'very
" magic' regexes.
nnoremap / /\v
vnoremap / /\v

set incsearch       " show search matches as you type
set showmatch       " set show matching parenthesis
set hlsearch        " highlight search terms

" Clear the search highlighting by pressing \/
nnoremap <leader><space> :nohlsearch<cr>

"}}}

" Plug ------------------------------------------------------------------------- {{{
call plug#begin()
Plug 'altercation/vim-colors-solarized'
Plug 'benmills/vimux'
Plug 'Chun-Yang/vim-action-ag'
Plug 'ervandew/supertab' " Use tab for insert completion
Plug 'gabesoft/vim-ags',  { 'on' : ['Ags'] }
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'gmarik/Vundle.vim'
Plug 'godlygeek/csapprox'
Plug 'godlygeek/tabular'
Plug 'https://shanematley@bitbucket.org/shanematley/cppguards.git'
Plug 'itchyny/lightline.vim'
Plug 'justinmk/vim-sneak'
Plug 'justinmk/vim-syntax-extra'
Plug 'kana/vim-scratch'
Plug 'kien/ctrlp.vim'
Plug 'majutsushi/tagbar', { 'on' : 'TagbarOpenAutoClose' }
Plug 'mileszs/ack.vim'
Plug 'moll/vim-bbye'
Plug 'NLKNguyen/papercolor-theme'
Plug 'PeterRincker/vim-argumentative' " Shift arguments with <, >, Move between argument boundaries with [, ], New text objects a, i,
Plug 'rhysd/vim-clang-format', {'on': 'ClangFormat'}
Plug 'richq/cmakecompletion-vim', {'for' : 'cmake' } " C-X C-O for completion of cmake;  K mapping for help
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Shirk/vim-gas', { 'for' : 'gas' }
Plug 'sjbach/lusty' ", { 'on' : ['LustyJuggler', 'LustyBufferExplorer', 'LustyFilesystemExplorerFromHere'] }
Plug 'sjl/badwolf'
Plug 'sjl/gundo.vim'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-characterize'
Plug 'tpope/vim-dispatch', { 'on' : ['Make', 'Start', 'Dispatch', 'FocusDispatch', 'Copen'] }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'vim-scripts/a.vim' " Switch header/source with :A and <leader>-s/S
Plug 'vim-scripts/closetag.vim' " Close previous tag with C--
Plug 'vim-scripts/genutils'
Plug 'vim-scripts/SelectBuf' " F3 displays open buffers + deletion capability
Plug 'vim-scripts/vim-indent-object' " ai, ii, aI, iI (an/inner indentation level and line above/below)
Plug 'xuhdev/SingleCompile', { 'on' : [ 'SCChooseCompiler',     'SCCompile',            'SCCompileRun',         'SCCompileRunAsync', 'SCChooseInterpreter',  'SCCompileAF',          'SCCompileRunAF',       'SCCompileRunAsyncAF' ] }
Plug 'yegappan/grep'
call plug#end()
"}}}

" Plugin configuration: lightline {{{
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

function! StatusModified()
  return &ft =~ 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! StatusReadonly()
  return &ft !~? 'help' && &readonly ? "\ue0a2" : ''
endfunction

function! StatusFileName()
  let fname = expand('%:t')
  return fname == 'ControlP' ? g:lightline.ctrlp_item :
        \ fname == '__Tagbar__' ? g:lightline.fname :
        \ fname == 'search-results.agsv' ? split(ags#get_status_string())[2] :
        \ fname =~ '__Gundo\|NERD_tree' ? '' :
        \ ('' != StatusReadonly() ? StatusReadonly() . ' ' : '') .
        \ ('' != fname ? fname : '[No Name]') .
        \ ('' != StatusModified() ? ' ' . StatusModified() : '')
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
"}}}
" Plugin configuration: tagbar {{{
nnoremap <silent> <F8> :TagbarOpenAutoClose<CR>
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
"}}}
" Plugin configuration: vim-gas {{{
function! ViewASM(file, gccargs)
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
command! -nargs=* ViewASM call ViewASM(expand('%'), <q-args>)
"}}}
"{{{ Plugin configuration: SingleCompile
function! SingleCompileGCC()
    let l:gcc=sort(glob(exepath("g++") . "*", 1, 1))[-1]
    call SingleCompile#SetCompilerTemplate('cpp', l:gcc, 'GNU C++1y Compiler', l:gcc, '-std=c++1z -pthread -Wall -Wextra -Weffc++ -isystem. -x c++ -o "$(FILE_TITLE)$"', '"./$(FILE_TITLE)$"')
    call SingleCompile#SetOutfile('cpp', l:gcc, '"$(FILE_TITLE)$"')
    call SingleCompile#ChooseCompiler('cpp', l:gcc)
endfunction
autocmd! User SingleCompile call SingleCompileGCC()

nnoremap <silent> <F9> :SCCompile<cr>:clist<cr>
nnoremap <silent> <F10> :SCCompileRun<cr>:clist<cr>
"}}}
" Plugin configuration: vim-clang-format {{{
let g:clang_format#code_style='google'
autocmd FileType c,cpp nnoremap <buffer> gR :.ClangFormat<CR>
autocmd FileType c,cpp vnoremap <buffer> gR :ClangFormat<CR>
"}}}
" Plugin configuration: papercolor-theme {{{
let g:PaperColor_Theme_Options = {
  \   'language': {
  \     'python': {
  \       'highlight_builtins' : 1
  \     },
  \     'cpp': {
  \       'highlight_standard_library': 1
  \     },
  \     'c': {
  \       'highlight_builtins' : 1
  \     }
  \   }
  \ }
"}}}
" Plugin configuration: vim-sneak {{{
let g:sneak#streak = 1
"}}}
" Plugin configuration: lusty {{{
let g:LustyJugglerShowKeys = 'a'
let g:LustyJugglerAltTabMode = 1
"}}}
" Plugin configuration: ctrlp.vim {{{
let g:ctrlp_map='<leader>t'
let g:ctrlp_max_files=20000
let g:ctrlp_max_depth=8
let g:ctrlp_custom_ignore = {
            \ 'dir': '\v[\/](\.(git|hg|svn)|venv|tmp)$',
            \ 'file': '\v\.(exe|so|dll|pyc|class|jar|java|xdc|tar.gz)$'
            \ }

let g:ctrlp_status_func = {
  \ 'main': 'CtrlPStatusFunc_1',
  \ 'prog': 'CtrlPStatusFunc_2',
  \ }

function! CtrlPStatusFunc_1(focus, byfname, regex, prev, item, next, marked)
  let g:lightline.ctrlp_regex = a:regex
  let g:lightline.ctrlp_prev = a:prev
  let g:lightline.ctrlp_item = a:item
  let g:lightline.ctrlp_next = a:next
  return lightline#statusline(0)
endfunction

function! CtrlPStatusFunc_2(str)
  return lightline#statusline(0)
endfunction

" The following permits deletion of buffers
let g:ctrlp_buffer_func = { 'enter': 'MyCtrlPMappings' }
func! MyCtrlPMappings()
    nnoremap <buffer> <silent> <c-@> :call <sid>DeleteBuffer()<cr>
endfunc
func! s:DeleteBuffer()
    let line = getline('.')
    let bufid = line =~ '\[\d\+\*No Name\]$' ? str2nr(matchstr(line, '\d\+'))
        \ : fnamemodify(line[2:], ':p')
    exec "bd" bufid
    exec "norm \<F5>"
endfunc
"}}}
" Plugin configuration: Tabularize {{{
if exists(":Tabularize")
    " Note if reusing this in a straight command, remove the second '\' before
    " the pipe.
    "nnoremap <Leader>ac :Tabularize /\("[^"]*"\\|[^",]*\),\zs/l0l1<CR>
    " Line up on arguments
    nnoremap <Leader>ac :Tabularize /\v("[^"]*"\|[^",]*),\zs/l0l1<CR>
    vnoremap <Leader>ac :Tabularize /\("[^"]*"\\|[^",]*\),\zs/l0l1<CR>
    " Line up on method variables (underscores at beginning)
    nnoremap <Leader>am :Tabularize /\<_\ze.*/l1l0<CR>
    vnoremap <Leader>am :Tabularize /\<_\ze.*/l1l0<CR>
    " Line up on ...???
    nnoremap <Leader>ap :Tabularize /\(^[^(]*(\zs.*$\\|^\s*\zs[^(]*$\)/l0l0<CR>
    vnoremap <Leader>ap :Tabularize /\(^[^(]*(\zs.*$\\|^\s*\zs[^(]*$\)/l0l0<CR>
    " Line up typedefs
    vnoremap <Leader>at :Tabularize /.\{-}\zs[^ ]*$/l1l0<CR>
    nnoremap <Leader>at :Tabularize /.\{-}\zs[^ ]*$/l1l0<CR>
    " Line up on variable name and =
    " Note: \h\w+ is any valid c++ identifier
    vnoremap <Leader>av :Tabularize /\v(\=\|\h\w+\ze\s*\=)/<CR>
    nnoremap <Leader>av :Tabularize /\v(\=\|\h\w+\ze\s*\=)/<CR>
    " Line up on open brace '{'
    vnoremap <Leader>a[ :Tabularize /{.*/<CR>
    nnoremap <Leader>a[ :Tabularize /{.*/<CR>
endif
"s/"\([^"]\+\)"/\=substitute(submatch(0), ',', '__;__', 'g')/g | gv | Tabular /,\zs

" Format arguments with apace after comma
nnoremap <Leader>f, :s/,\ze[^ ]/, /g<CR>
vnoremap <Leader>f, :s/,\ze[^ ]/, /g<CR>

"}}}
" Plugin configuration: gundo {{{
let g:gundo_preview_bottom=1
"}}}
" Plugin configuratino: NERDTree {{{
nnoremap <leader>r :NERDTreeFind<cr>
nnoremap <leader>n :NERDTreeToggle<cr>
let NERDTreeIgnore=['\.pyc$', '\~$']
"}}}

" YouCompleteMe ---------------------------------------------------------------- {{{
if filereadable(glob(b:local_vim_files . "ycmconf.py"))
    let g:ycm_global_ycm_extra_conf = b:local_vim_files . 'ycmconf.py'
endif
let s:uname = system('uname')
if s:uname == "SunOs\n" || v:version < 703 || (v:version == 703 && !has('patch584'))
    set runtimepath-=~/.vim/bundle/YouCompleteMe
endif
"}}}

" Ignored files ---------------------------------------------------------------- {{{
set wildignore+=*.o,*.obj,*.git,*.bzr,*.pyc,*~,*/build/*
"}}}

" VIM User Interface ----------------------------------------------------------- {{{
set hidden
set backspace=indent,eol,start " allow backspacing over everything in insert mode
set number          " always show line numbers
set undolevels=1000
set visualbell      " don't beep
set noerrorbells    " don't beep
set splitbelow
set splitright
set scrolloff=1
set wildignore+=*.o,*.obj,*.git,*.bzr,*.pyc,*~
set wildignore+=venv/**,tmp/**
set lazyredraw      " redraw only when needed

set encoding=utf-8

if has('gui_running')
    " remove the menu bar and toolbar
    set guioptions-=m
    set guioptions-=T
    set showtabline=2

    if has("gui_mac") && has("gui_gnome")
        set term=gnome-256color
        colorscheme molokai
        set guifont=Monospace\ Bold\ 12
    endif

    if has("gui_mac") || has("gui_macvim")
        set guifont=Fira\ Code:h13,Hack:h13,Andale\ Mono:h13
        set transparency=7
    endif

    if has("gui_win32") || has("gui_win32s")
        set guifont=Consolas:h10
        set enc=utf-8
    endif
endif
"}}}

" Text, tabs, indenting etc ---------------------------------------------------- {{{
set expandtab
set smarttab        " insert tabs on the start of a line according to shiftwidth, not tabstop
set tabstop=4       " a tab is four spaces
set shiftwidth=4    " number of spaces to use for autoindenting
set autoindent      " always set autoindenting on
set copyindent      " copy the previous indentation on autoindenting
set softtabstop=4
set shiftround      " use multiple of shiftwidth when indenting with '<' and '>'
set nowrap          " don't wrap lines
set cursorline      " highlight the current row
set showbreak=↪

" tabs to two spaces in html/xml files
augroup filetype_html
    autocmd!
    autocmd FileType html,xml setlocal ts=2 sts=2 sw=2
augroup END

augroup filetype_GNUmakefile
    autocmd!
    autocmd BufRead,BufNewFile GNUmakefile setlocal expandtab
augroup END

augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END
"}}}

" Visual Mode ------------------------------------------------------------------ {{{
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>
"}}}

" File Handling ---------------------------------------------------------------- {{{
" When displaying a target buffer switch to the relevant tab or open in a new
" tab. Affects such commands as quickfix open and buffering switching commands.
try
    "set switchbuf=usetab,newtab
    set stal=2
catch
endtry

set modelines=1     " commands in a file on how VIM is to display the file
set nobackup
set noswapfile
"}}}

" Project Specific Settings ---------------------------------------------------- {{{

function! s:LoadProjectSpecificSettings()
    if filereadable("./.vimrc.project")
        source ./.vimrc.project
        echom "Loaded local project settings from .vimrc.project"
    endif
endfunction
com! LoadLocalProjectSpecificSettings call s:LoadProjectSpecificSettings()

"}}}

" Shortcut Keys, Mappings ------------------------------------------------------ {{{

nnoremap ZX :qa<CR>
nnoremap <leader>b :CtrlPBuffer<cr>
nnoremap <leader>ps :LoadLocalProjectSpecificSettings<cr>

nnoremap <leader>m :silent Make<cr>

" A command to execute an external command without requiring the user
" to press Enter to dismiss a prompt.
command! -nargs=1 Silent
            \ | execute ':silent !'.<q-args>
            \ | execute ':redraw!'

command! -nargs=* -bar Silent2 make <args> <bar> cwindow

function! OpenCurrentFile()
    if (&ft=='markdown')
        echom "Opened " . expand("%") . " in Marked 2"
        exec "Silent open \"marked://open?file=" . expand("%:p") . "\""
        exec "Silent open \"marked://style/" . expand("%:t:r") . "?css=Meeting\ Markdown\""
        exec "Silent open marked://refresh"
    else
        echom "Opened " . expand("%") . " in default Mac viewing application"
        exec "Silent open " . shellescape(expand("%"))
    endif
endfunction

" Use <leader>o to open in external viewer on Mac.
if has("mac") || has("macunix")
    "nnoremap <leader>o :exe "Silent open " . shellescape(expand("%"))<cr>
    nnoremap <leader>o :call OpenCurrentFile()<cr>
endif

" Move line down
nnoremap - ddp
" Move line up
nnoremap _ ddkP
" Delete current line in insert mode
inoremap <leader><c-d> <esc>ddi
" Uppercase current word
nnoremap <leader><c-u> viwU
" Lowercase current word
nnoremap <leader><c-l> viwu

" Use movement by screen line as opposed to file line
nnoremap j gj
nnoremap k gk

" Navigate vimgrep/grep/anything in copen results
noremap <Space>n :cnext<C-m>
noremap <Space>p :cprev<C-m>

" Strip all training whitespace in the current file. the let part of the
" command seems to empty the last search register
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Reselect the text that was just pasted
nnoremap <leader>v `V`]

" Make Y consistent with C and D by copying to the end of the line
nnoremap Y y$

" Quickly open vimrc, bashrc and zshrc in a vsplit, and source ~/.vimrc
nnoremap <leader>ez :vsplit ~/.zshrc<cr>
nnoremap <leader>eb :vsplit ~/.bashrc<cr>
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Use jj to exit back to normal mode without hitting ESC
inoremap jj <ESC>
inoremap JJ <ESC>
inoremap jk <ESC>
inoremap JK <ESC>

" Switch PWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Open a new vertical split and switch to it. Use <C-w>s to get a horizontal split
nnoremap <leader>w <C-w>v<C-w>l

" Quick navigation of windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Quick navigation of tabs
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tJ  :tabmove +1<CR>
nnoremap tk  :tabprev<CR>
nnoremap tK  :tabmove -1<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnext<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>
nnoremap tc  :tabnew<cr>
nnoremap tO  :tabonly<cr>
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
nnoremap <silent><Leader><C-]> <C-w><C-]><C-w>T
let g:lasttab = 1
nmap t; :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Open up a scratch buffer quickly
nnoremap <leader><tab> :ScratchOpen<cr>

" Show yankring
nnoremap <silent> <F2> :YRShow<cr>
inoremap <silent> <F2> <ESC>:YRShow<cr>

" Gundo toggle
nnoremap <leader>u :GundoToggle<CR>

" Move a line of text using ALT+[jk] or Command+[jk] on mac
nmap <M-j> mz:m+<cr>$z
nmap <M-k> mz:m-2<cr>$z
vmap <M-j> :m'>+<cr>$<my$>mzgv$yo$z
vmap <M-k> :m'<-2<cr>$>my$<mzgv$yo$z

if has("mac") || has("macunix")
  nmap <D-j> <M-j>
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-k> <M-k>
endif

" date/time insertion
inoremap <leader>ds <C-R>=strftime("%Y-%m-%d %T")<CR>
inoremap <leader>ymd <C-R>=strftime("%Y-%m-%d")<CR>
inoremap <leader>hms <C-R>=strftime("%T")<CR>
inoremap <leader>dl <C-R>=strftime("%A, %d %b %Y")<CR>

" Shortcut to perform substitution
nnoremap gs :%s//g<Left><Left>

" Vimux shortcuts
map <Leader>vl :VimuxRunLastCommand<CR>
map <Leader>vp :VimuxPromptCommand<CR>
map <Leader>vi :VimuxInspectRunner<CR>
map <Leader>vz :VimuxZoomRunner<CR>

"}}}

"{{{ Custom diff commands

" diff current file from last written

if executable('colordiff')
    nnoremap <leader>diff :write !diff -du % - \| colordiff<CR>
else
    nnoremap <leader>diff :write !diff -du % -<CR>
endif

function! s:DiffWithSaved()
    let filetype=&ft
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

function! s:DiffWithGITCheckedOut()
    let filetype=&ft
    diffthis
    vnew | exe "%!git diff " . expand("#:p") . "| patch -p 1 -Rs -o /dev/stdout"
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
    diffthis
endfunction
com! DiffGit call s:DiffWithGITCheckedOut()

function! s:DiffWithPerforceCheckedOut()
    let filetype=&ft
    diffthis
    vnew | exe "%!p4 diff -du " . expand("#:p") . "...| patch -p0 -Rs -o /dev/stdout"
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
    diffthis
endfunction
com! DiffPerforce call s:DiffWithPerforceCheckedOut()

"}}}

"{{{ show whitespace except in html and xml files
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
augroup filetype_html_listchars
    autocmd!
    autocmd FileType html,xml setlocal listchars-=tab:>.
augroup END
augroup filetype_asm
    autocmd!
    autocmd FileType asm setlocal nolist
augroup END
"}}}

" Setup syntax for log, ipp, ixx, tpp and txx {{{
syntax on
filetype on
filetype plugin indent on
au BufNewFile,BufRead *.log set FileType=log
au BufNewFile,BufRead *.ipp set FileType=cpp
au BufNewFile,BufRead *.ixx set FileType=cpp
au BufNewFile,BufRead *.tpp set FileType=cpp
au BufNewFile,BufRead *.txx set FileType=cpp
"}}}

" Plugin Shortcuts ------------------------------------------------------------- {{{

" to insert the special character below, type Ctrl-v then '[', but don't let go of Ctrl
map s :A<CR>
map <leader>s :A<CR>
nnoremap <leader>S <C-w>v<C-w>l:A<CR>

" <C-W>! -> Close buffer without closing window {{{
nmap <C-W>! :Bdelete<CR>
"}}}

" leader key is set to \ by default, to change: letmapleader = ","
map <leader>pp :setlocal paste!<cr>

" Provide for /// comments and //
augroup cpp_comments
    autocmd!
    autocmd FileType c,cpp,h,hpp,cxx,txx,ixx,ipp setlocal comments-=:// comments+=:///,://
augroup END
"}}}

" Status Line ------------------------------------------------------------------ {{{
set statusline=%-3.3n\ \        " BufferNum
set statusline+=%{HasPaste()}   " Paste mode
set statusline+=%F              " File name
set statusline+=%m              " Modified flag
set statusline+=%r\             " Read only flag
set statusline+=(%{FileSize()}) " File size
set statusline+=%h\             " Help file flag
set statusline+=%w              " Preview window flag
set statusline+=%=              " Align the remainder on the right
set statusline+=L:%l/%L\        " L:Current line/total lines
set statusline+=(%p%%)\         " Percent through file
set statusline+=C:%c\           " C:Column number
set statusline+=[%Y,%{&ff}]     " [File processing type, line ending type]
set laststatus=2    " Always show statusline

if has ("spell")
    set spelllang=en_gb
    "nnoremap <leader>s :set spell!<CR>
endif

if has ("folding")
    set foldenable
endif
"}}}

" Colours and Fonts ------------------------------------------------------------ {{{
syntax enable

if has("gui_running")
    set t_Co=256
    set guitablabel=%M\ %t
endif

set background=dark
colorscheme PaperColor

call togglebg#map("<F5>")
hi MatchParen ctermbg=blue guibg=lightblue
"}}}

" Tab Line settings ------------------------------------------------------ {{{
if exists("+showtabline")
  function! MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
      " set up some oft-used variables
      let tab = i + 1 " range() starts at 0
      let winnr = tabpagewinnr(tab) " gets current window of current tab
      let buflist = tabpagebuflist(tab) " list of buffers associated with the windows in the current tab
      let bufnr = buflist[winnr - 1] " current buffer number
      let bufname = bufname(bufnr) " gets the name of the current buffer in the current window of the current tab

      let s .= '%' . tab . 'T' " start a tab
      let s .= (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#') " if this tab is the current tab...set the right highlighting
      let s .= ' ' . tab .':' " current tab number
      let n = tabpagewinnr(tab,'$') " get the number of windows in the current tab
      let bufmodified = getbufvar(bufnr, "&mod")
      if bufmodified
        let s .= ' +'
      endif
      if bufname != ''
        let s .= ' [' . pathshorten(bufname) . ']' " outputs the one-letter-path shorthand & filename
      else
        let s .= ' [No Name]'
      endif
      if n > 1
        let s .= '(' . n . ')' " if there's more than one, add a colon and display the count
      endif
      "let s .= ' '
    endfor
    let s .= '%#TabLineFill#' " blank highlighting between the tabs and the righthand close 'X'
    let s .= '%T' " resets tab page number?
    let s .= '%=' " seperate left-aligned from right-aligned
    let s .= '%#TabLine#' " set highlight for the 'X' below
    let s .= '%999XX' " places an 'X' at the far-right
    return s
  endfunction
  set tabline=%!MyTabLine()
endif
"}}}

" Diff settings ---------------------------------------------------------- {{{
set diffopt+=iwhite
"}}}

" Custom functions ------------------------------------------------------- {{{

" Output long VIM commands in a more raedable format. E.g.
" :Bufferize digraphs or :Bufferize maps or :Bufferize let g:
command! -nargs=* -complete=command Bufferize call s:Bufferize(<q-args>)
function! s:Bufferize(cmd)
    let cmd = a:cmd
    redir => output
    silent exe cmd
    redir END

    new
    setlocal nonumber
    call setline(1, split(output, "\n"))
    set nomodified
endfunction

" Insert digraphs by typing the letters then C-n rather than the normal
" way of entering diagraph mode with C-k and typing the two keys.
inoremap <C-n> <esc>:call <SID>Digraph()<cr>a
function! s:Digraph()
    let col = col('.')
    let chars = getline('.')[col - 2 : col - 1]
    exe "normal! s\<esc>s\<c-k>".chars
endfunction

"}}}

" Clang Format ----------------------------------------------------------- {{{
" Assume clang-format.py lives in ~/bin

"noremap <leader>cf :pyf $HOME/bin/clang-format.py<cr>
"noremap <leader>cf :execute "normal! :pyf $HOME/bin/clang-format.py"<cr>
noremap <leader>cf :pyf $HOME/bin/clang-format.py<cr>
inoremap <leader>cf <c-o>:pyf $HOME/bin/clang-format.py<cr>

function! ClangCheckImpl(cmd)
  if &autowrite | wall | endif
  echo "Running " . a:cmd . " ..."
  let l:output = system(a:cmd)
  cexpr l:output
  cwindow
  let w:quickfix_title = a:cmd
  if v:shell_error != 0
    cc
  endif
  let g:clang_check_last_cmd = a:cmd
endfunction

function! ClangCheck()
  let l:filename = expand('%')
  if l:filename =~ '\.\(cpp\|cxx\|cc\|c\)$'
    call ClangCheckImpl("clang-check " . l:filename)
  elseif exists("g:clang_check_last_cmd")
    call ClangCheckImpl(g:clang_check_last_cmd)
  else
    echo "Can't detect file's compilation arguments and no previous clang-check invocation!"
  endif
endfunction

nmap <leader>cc :call ClangCheck()<CR><CR>

"}}}

" Load any local .vim.local files
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif
call s:LoadProjectSpecificSettings()

if exists("g:btm_rainbow_color") && g:btm_rainbow_color
   call rainbow_parenthsis#LoadSquare ()
   call rainbow_parenthsis#LoadRound ()
   call rainbow_parenthsis#Activate ()
endif

augroup filetype_markdown
    autocmd!
    autocmd BufNewFile,BufRead *.md set FileType=markdown
augroup END

" First tab completes as much as possible; second provides a list; third
" starts cyclying through the options
set wildmode=longest,list,full
set wildmenu

if exists("&wildignorecase")
    set wildignorecase
endif

" Helper Functions ------------------------------------------------------------- {{{

function! VisualSelection(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    else
        return ''
    endif
endfunction

function! FileSize()
    let bytes = getfsize(expand("%:p"))
    if bytes <= 0
        return ""
    endif
    if bytes < 1024
        return bytes
    else
        return (bytes / 1024) . "K"
    endif
endfunction

" A command to insert a series of spaces up to line designated by the repeat
" count
function! SpacesToColumn(count)
    exe "norm! 100A\<Space>\<Esc>d" . a:count . "\<Bar>"
endfunction
"com! -nargs=1 SpacesToColumn exe "norm! 100A<Space><Esc>d<args><Bar>"
nnoremap <leader>f<space> :<C-U>call SpacesToColumn(v:count)<CR>

" Expand public/private/protected
iabbrev pub: public:
iabbrev pri: private:
iabbrev pro: protected:
iabbrev stdos std::ostream
iabbrev stdoss std::ostringstream

" Toggles a charater at the end, used below for <leader>; to toggle end semi-colon
function! ToggleEndChar(charToMatch)
    exec "norm! m`"
    s/\v(.)$/\=submatch(1)==a:charToMatch ? '' : submatch(1).a:charToMatch
    exec "norm! ``"
endfunction
nnoremap <leader>; :call ToggleEndChar(';')<CR>

let g:ctags_statusline=1

nnoremap <leader>f_ /_[^_]\+_<cr>

function! s:get_visual_selection()
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

function! NsToString(ns)
    let m = matchlist(a:ns, '\v(\d+)(\d{9})')
    if empty(m)
        throw "No nanosecond timestamp in ".a:ns
    endif
    return strftime("%Y-%m-%d %H:%M:%S", str2nr(m[1])).'.'.m[2]
endfunction

"nnoremap <leader>l yiwciw<C-r>=NsToString('<C-r>"')<cr><esc>
"nnoremap <leader>L yiwea (<C-r>=NsToString('<C-r>"')<cr>)<esc>

" vim:fdm=marker
