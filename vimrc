" eXTENSIbility points
" There is one file specifically looked for in b:local_vim_files:
" * ycmconf.py      -- Configuration for YouCompleteMe. (Also requires the
"                      YouCompleteMe plugin to be added in the first place
"                      by adding the bundle to vundle.vimrc)
"
" Additionally ~/.vimrc.local is loaded at some point for local config.

let b:local_vim_files = "~/.vim/local/"

let mapleader = ","
:nmap <space> ,

filetype plugin indent on

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
Plug 'ervandew/supertab' " Use tab for insert completion
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
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
call plug#end()
"}}}

nnoremap <silent> <F8> :TagbarOpenAutoClose<CR>

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
        set guifont=Fira\ Code:h12,Hack:h13,Andale\ Mono:h13
        set transparency=7
    endif

    if has("gui_win32") || has("gui_win32s")
        set guifont=Consolas:h10
        set enc=utf-8
    endif
endif
"}}}

" Text, tabs, indenting etc ---------------------------------------------------- {{{

" default indent settings
set autoindent      " use indent of previous line on new lines
set expandtab       " use spaces instead of tabs
set shiftwidth=4    " number of spaces to use for autoindenting
set softtabstop=4   " number of spaces to insert with tab key

set copyindent      " copy the previous indentation on autoindenting
set shiftround      " use multiple of shiftwidth when indenting with '<' and '>'
set nowrap          " don't wrap lines

set cursorline      " highlight the current row

" Prefix wrapped rows
set showbreak=...

" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * <Plug>VisualSelectionSearchForward
vnoremap <silent> # <Plug>VisualSelectionSearchBackward
"}}}

" File Handling ---------------------------------------------------------------- {{{
" When displaying a target buffer switch to the relevant tab or open in a new
" tab. Affects such commands as quickfix open and buffering switching commands.
try
    "set switchbuf=usetab,newtab
    set stal=2
catch
endtry

" Don't allow setting options via buffer context
set nomodeline
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
nnoremap <leader>b :Buffers<cr>
nnoremap <leader>t :GFiles<cr>
nnoremap <leader>ps :LoadLocalProjectSpecificSettings<cr>

nnoremap <leader>m :silent Make<cr>

noremap <leader>va :Gblame<CR>
noremap gh :Glog<CR>

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

set list

" Define extra 'list' display characters
set listchars=tab:>-,trail:.,extends:>,precedes:<
silent set listchars+=nbsp:+

nnoremap <leader>s :A<CR>
nnoremap <leader>S <C-w>v<C-w>l:A<CR>

" "in line" (entire line sans white-space; cursor at beginning)
xnoremap <silent> il :<c-u>normal! g_v^<cr>
onoremap <silent> il :<c-u>normal! g_v^<cr>
xnoremap <silent> al :<c-u>normal! $v0<cr>
onoremap <silent> al :<c-u>normal! $v0<cr>
" "in number" (next number after cursor on current line)
xmap <silent> in <Plug>(XInNumber)
omap <silent> in <Plug>(OInNumber)
" "around number" (next number on line and possible surrounding white-space)
xmap <silent> an <Plug>(XAroundNumber)
omap <silent> an <Plug>(OAroundNumber)

nmap <C-W>! :Bdelete<CR>  " close buffer without closing window

noremap <leader>pp :setlocal paste!<cr>

set laststatus=2    " Always show statusline

if has ("spell")
    set spelllang=en_gb
    "nnoremap <leader>s :set spell!<CR>
endif

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

" Insert digraphs by typing the letters then C-n rather than the normal
" way of entering diagraph mode with C-k and typing the two keys.
imap <C-n> <Plug>(DigraphFromPrevChars)

" Map double Ctrl-K in insert mode to search digraph names
" Run :helptags ~/.vim/doc to generate docs
imap <C-K><C-K> <Plug>(DigraphSearch)

" Clang Format ----------------------------------------------------------- {{{
" Assume clang-format.py lives in ~/bin

noremap <leader>cf :pyf $HOME/bin/clang-format.py<cr>
nmap <leader>cc <Plug>(RunClangCheck)

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

" First tab completes as much as possible; second provides a list; third
" starts cyclying through the options
set wildmode=longest,list,full
set wildmenu

if exists("&wildignorecase")
    set wildignorecase
endif

" Helper Functions ------------------------------------------------------------- {{{

" A command to insert a series of spaces up to line designated by the repeat
" count
function! SpacesToColumn(count)
    exe "norm! 100A\<Space>\<Esc>d" . a:count . "\<Bar>"
endfunction
nnoremap <leader>f<space> :<C-U>call SpacesToColumn(v:count)<CR>

nmap <leader>; <Plug>(ToggleSemicolonAtEnd)   " toggle semicolon at end of line

let g:ctags_statusline=1

" Don't display splash screen on start
set shortmess+=I

" vim:fdm=marker
