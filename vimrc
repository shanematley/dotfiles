" Extensibility points
" There are two files specifically looked for in b:local_vim_files:
" * vundle.vimrc -- Add any required Vundle bundles in here
" * ycmconf.py      -- Configuration for YouCompleteMe. (Also requires the
"                      YouCompleteMe plugin to be added in the first place
"                      by adding the bundle to vundle.vimrc)
"
" Additionally ~/.vimrc.local is loaded at some point for local config.

let b:local_vim_files = "~/.vim/local/"

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

" Vundle ----------------------------------------------------------------------- {{{
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
if filereadable(glob(b:local_vim_files . "vundle.vimrc"))
    " Put "Bundle 'Valloric/YouCompleteMe'" in the following if desired:
    execute 'source' b:local_vim_files . "vundle.vimrc"
endif
Plugin 'kana/vim-scratch'
" Use tab for insert completion
Plugin 'ervandew/supertab'
Plugin 'vim-scripts/genutils'
" F3 displays open buffers + deletion capability
Plugin 'vim-scripts/SelectBuf'
" Switch header/source with :A and <leader>-s/S
Plugin 'vim-scripts/a.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'godlygeek/csapprox'
Plugin 'godlygeek/tabular'
Plugin 'kien/ctrlp.vim'
Plugin 'mileszs/ack.vim'
Plugin 'moll/vim-bbye.git'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-characterize'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
" Close previous tag with C--
Plugin 'vim-scripts/closetag.vim'
Plugin 'yegappan/grep'
Plugin 'sjl/gundo.vim'
Plugin 'https://shanematley@bitbucket.org/shanematley/cppguards.git'

call vundle#end()
filetype plugin indent on
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

" Ctrl-P ----------------------------------------------------------------------- {{{
let g:ctrlp_map='<leader>t'
let g:ctrlp_max_files=0
"if has ("unix")
"    let g:ctrlp_user_command = {
"      \ 'types': {
"        \ 1: ['.git/', 'cd %s && git ls-files'],
"        \ 2: ['.hg/', 'hg --cwd %s locate -I .'],
"        \ },
"      \ 'fallback': 'find %s -type f'
"      \ }
""            \ 'fallback': 'find %s -type f'
"endif

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

set encoding=utf-8

if has('gui_running')
    set lines=37 columns=135
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
        set guifont=Source\ Code\ Pro:h14
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

" tabs to two spaces in html/xml files
augroup filetype_html
    autocmd!
    autocmd filetype html,xml setlocal ts=2 sts=2 sw=2
augroup END

augroup filetype_GNUmakefile
    autocmd!
    autocmd BufRead,BufNewFile GNUmakefile setlocal expandtab
augroup END

augroup filetype_vim
    autocmd!
    autocmd filetype vim setlocal foldmethod=marker
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
    set switchbuf=usetab,newtab
    set stal=2
catch
endtry

set modelines=0     " commands in a file on how VIM is to display the file
set nobackup
set noswapfile
"}}}

" Shortcut Keys, Mappings ------------------------------------------------------ {{{
let mapleader = ","

nnoremap <leader>b :CtrlPBuffer<cr>

" A command to execute an external command without requiring the user
" to press Enter to dismiss a prompt.
command! -nargs=1 Silent
            \ | execute ':silent !'.<q-args>
            \ | execute ':redraw!'

" Use <leader>o to open in external viewer on Mac.
if has("mac") || has("macunix")
    nnoremap <leader>o :exe "Silent open " . shellescape(expand("%"))<cr>
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

" Strip all training whitespace in the current file. the let part of the
" command seems to empty the last search register
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

" Reselect the text that was just pasted
nnoremap <leader>v V`]

" Quickly open and source ~/.vimrc in a vertically split window
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
nnoremap <F10> :GundoToggle<CR>

" Move to matched bracket pairs using tab instead of %.
nnoremap <tab> %
vnoremap <tab> %

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
"}}}

"{{{ show whitespace except in html and xml files
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.
augroup filetype_html_listchars
    autocmd!
    autocmd filetype html,xml setlocal listchars-=tab:>.
augroup END
augroup filetype_asm
    autocmd!
    autocmd filetype asm setlocal nolist
augroup END
"}}}

" Setup syntax for log, ipp, ixx, tpp and txx {{{
syntax on
filetype on
filetype plugin indent on
au BufNewFile,BufRead *.log set filetype=log
au BufNewFile,BufRead *.ipp set filetype=cpp
au BufNewFile,BufRead *.ixx set filetype=cpp
au BufNewFile,BufRead *.tpp set filetype=cpp
au BufNewFile,BufRead *.txx set filetype=cpp
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
else
    let g:solarized_termcolors=256
endif

set background=dark
colorscheme solarized

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

if exists(":Tabularize")
    " Note if reusing this in a straight command, remove the second '\' before
    " the pipe.
    "nnoremap <Leader>ac :Tabularize /\("[^"]*"\\|[^",]*\),\zs/l0l1<CR>
    nnoremap <Leader>ac :Tabularize /\v("[^"]*"\|[^",]*),\zs/l0l1<CR>
    vnoremap <Leader>ac :Tabularize /\("[^"]*"\\|[^",]*\),\zs/l0l1<CR>
    nnoremap <Leader>am :Tabularize /\<_/l1l0<CR>
    vnoremap <Leader>am :Tabularize /\<_/l1l0<CR>
endif
"s/"\([^"]\+\)"/\=substitute(submatch(0), ',', '__;__', 'g')/g | gv | Tabular /,\zs

" Load any local .vim.local files
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" Note: nnoremap => n (Works in normal mode) nore (non-recursive, vs re for recursive) map
"nnoremap <silent> <F5> :Bgrep<CR>
nnoremap <F9> :vertical wincmd f<CR>
nnoremap <F7> :NERDTreeToggle<CR>
" F8 is tag list
nnoremap <leader>n :NERDTreeToggle<cr>
"nnoremap <F5> :cn<cr>
nnoremap <F6> :cp<cr>
"The following maps to Shift-F5 when using putty in Xterm R6 mode. Used C-V to
"insert character.
"nnoremap [28~ :cp<cr>
"nnoremap <F4> :cr<cr>
" for putty

if exists("g:btm_rainbow_color") && g:btm_rainbow_color
   call rainbow_parenthsis#LoadSquare ()
   call rainbow_parenthsis#LoadRound ()
   call rainbow_parenthsis#Activate ()
endif

function! MarkdownLevel()
    if getline(v:lnum) =~ '^# .*$'
        return ">1"
    endif
    if getline(v:lnum) =~ '^## .*$'
        return ">2"
    endif
    if getline(v:lnum) =~ '^### .*$'
        return ">3"
    endif
    if getline(v:lnum) =~ '^#### .*$'
        return ">4"
    endif
    if getline(v:lnum) =~ '^##### .*$'
        return ">5"
    endif
    if getline(v:lnum) =~ '^###### .*$'
        return ">6"
    endif
    return "="
endfunction
augroup filetype_markdown
    autocmd!
    autocmd BufNewFile,BufRead *.md set filetype=markdown
    autocmd BufEnter *.md setlocal foldexpr=MarkdownLevel()
    autocmd BufEnter *.md setlocal foldmethod=expr
    autocmd BufNewFile,BufRead *.md *.markdown set ai formatoptions=tcroqn2 comments=n:> tw=80
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

" Wrap word in const-ref
nnoremap <leader>cr viwbviconst<space><esc>ea&<esc>
nnoremap <leader>ncr viwbvdbf&x

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

" vim:fdm=marker
