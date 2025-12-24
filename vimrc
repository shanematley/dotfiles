let s:local_config_files_dir = expand('~/.vim/local')

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
elseif !has('nvim')
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
if has('nvim')
    call plug#begin("~/.config/nvim/plugged")
    Plug 'nvim-tree/nvim-web-devicons' " optional
    Plug 'nvim-tree/nvim-tree.lua'
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim', { 'tag': 'v0.2.0' }
    Plug 'mason-org/mason.nvim'
    Plug 'mason-org/mason-lspconfig.nvim'
    "Plug 'ibhagwan/fzf-lua', {'branch': 'main'}
    Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
    " Bazel support for go to definition, build/test/run buffer, jump to BUILD file, etc
    Plug 'stevearc/aerial.nvim'
else
    call plug#begin()
    Plug 'catppuccin/vim', { 'as': 'catppuccin' }
    " Python: :CocInstall coc-pyright
    " Installing for C++:
    " :CocInstall coc-clangd
    " Create compile_commands.json by cloning the following repo and running the
    " generate.py script when in bazel directory. https://github.com/grailbio/bazel-compilation-database
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " A tagbar on the side
    Plug 'majutsushi/tagbar', { 'on' : [ 'TagbarOpenAutoClose', 'TagbarToggle', 'TagbarOpen' ] }
    Plug 'rhysd/vim-clang-format', {'on': 'ClangFormat'}
    Plug 'preservim/nerdcommenter'
    Plug 'preservim/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] }
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'stsewd/fzf-checkout.vim' " Introduces :GBranches - FZF for git branches
Plug 'dense-analysis/ale'
endif

Plug 'airblade/vim-gitgutter'
Plug 'preservim/vimux'
Plug 'cappyzawa/starlark.vim', { 'for': 'starlark' }
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'justinmk/vim-sneak' " s followed by two characters
Plug 'moll/vim-bbye'  " Close buffers with Bdelete|Bwipeout without ruining window setup
Plug 'NLKNguyen/papercolor-theme'
Plug 'ojroques/vim-oscyank'
Plug 'PeterRincker/vim-argumentative' " Shift arguments with <, >, Move between argument boundaries with [, ], New text objects a, i,
Plug 'richq/cmakecompletion-vim', {'for' : 'cmake' } " C-X C-O for completion of cmake;  K mapping for help
Plug 'Shirk/vim-gas', { 'for' : 'gas' } " Syntax highlighting for GNU as
Plug 'mbbill/undotree'
Plug 'tommcdo/vim-exchange' " cx or cxx or X (visual mode) to exchange. cxc to clear
Plug 'tpope/vim-abolish' " Replacement with variations: :%Subvert/facilit{y,ies}/building{,s}/g
                         " Also: Press crs (coerce to snake_case). MixedCase (crm), camelCase (crc),
                         " snake_case (crs), UPPER_CASE (cru), dash-case (cr-), dot.case (cr.),
                         " space case (cr<space>), and Title Case (crt)
Plug 'tpope/vim-characterize' " Additional info with (ga) for character
Plug 'tpope/vim-dispatch', { 'on' : ['Make', 'Start', 'Dispatch', 'FocusDispatch', 'Copen'] }
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-projectionist' " A number of things, but includes :A, :AS, :AV, and :AT to jump to an 'alternate' file
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired' " [q/|]q for cprev|cnext; yos toggle spell; yon toggle numbers; [n|]n jump between conflict markers;
                            " [f|]f next/previous file in directory; yow toggle wrap
Plug 'vim-scripts/a.vim' " Switch header/source with :A and <leader>-s/S
Plug 'vim-scripts/genutils'
Plug 'vim-scripts/vim-indent-object' " ai, ii, aI, iI (an/inner indentation level and line above/below)
Plug 'junegunn/gv.vim'
Plug 'luochen1990/rainbow'
Plug 'will133/vim-dirdiff'

let s:local_plugged_config_files = globpath(s:local_config_files_dir, '**/*.plugged.vim', 0, 1)
for s:config_file in s:local_plugged_config_files
    execute 'source' s:config_file
endfor

call plug#end()
"}}}

if ! has('nvim')
    nnoremap <leader>b :Buffers<cr>
    nnoremap <leader>t :GFiles<cr>
    nnoremap <silent> <C-t> :Files<CR>
    nnoremap <silent> <leader>hh :History<CR>
    nnoremap <silent> <leader>h/ :History/<CR>
    nnoremap <silent> <leader>h; :History:<CR>
    nnoremap <silent> <leader>ll :Lines<CR>
    nnoremap <silent> <leader>lb :BLines<CR>
    nnoremap <silent> <leader>g :Rg<CR>
    nnoremap <silent> <leader>gb :GBranches<CR>
    nnoremap <silent> <leader>gs :GFiles?<CR>
    nnoremap <silent> <leader>gc :Commits<CR>
    nnoremap <silent> <leader>gh :BCommits<CR>
    nnoremap <leader>q :Rg <C-r><C-w><CR>
    nnoremap <leader>Q :Rg \b<C-r><C-w>\b<CR>
endif

nnoremap <silent> <leader>U :GitGutterUndoHunk<CR>
nnoremap <silent> <F2> :call CocAction('diagnosticNext')<cr>
nnoremap <silent> <S-F2> :call CocAction('diagnosticPrevious')<cr>

let g:rainbow_active = 0 "set to 0 if you want to enable it later via :RainbowToggle

" Use `s` to jump to a two character prefix
let g:sneak#label = 1

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

" Plugin configuratino: NERDTree {{{
if has('nvim')
    nnoremap <leader>nr :NvimTreeFindFile<cr>
    nnoremap <leader>nn :NvimTreeFocus<cr>
    nnoremap <leader>n :NvimTreeToggle<cr>
else
    nnoremap <leader>nr :NERDTreeFind<cr>
    nnoremap <leader>nn :NERDTreeFocus<cr>
    nnoremap <leader>n :NERDTreeToggle<cr>
    let NERDTreeIgnore=['\.pyc$', '\~$']
endif
"}}}

"""{{{ Plugin configuration: vim-dirdiff
let g:DirDiffAddArgs = "-w"
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
    highlight Comment cterm=italic gui=italic
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

"{{{ FZF plugin (not the LUA version)

if ! has('nvim')
    let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit',
    \ 'ctrl-y': {lines -> setreg('+', join(lines, "\n"))}}

    " Customize fzf colors to match your color scheme
    " - fzf#wrap translates this to a set of `--color` options
    let g:fzf_colors =
    \ { 'fg':      ['fg', 'Normal'],
    \ 'bg':      ['bg', 'Normal'],
    \ 'hl':      ['fg', 'Comment'],
    \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
    \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
    \ 'hl+':     ['fg', 'Statement'],
    \ 'info':    ['fg', 'PreProc'],
    \ 'border':  ['fg', 'Ignore'],
    \ 'prompt':  ['fg', 'Conditional'],
    \ 'pointer': ['fg', 'Exception'],
    \ 'marker':  ['fg', 'Keyword'],
    \ 'spinner': ['fg', 'Label'],
    \ 'header':  ['fg', 'Comment'],
    \ 'preview-bg': ['bg', 'Normal'],
    \ 'preview-fg': ['fg', 'Normal'],
    \ }
endif

" Terminal colors for seoul256 color scheme
if has('nvim')
  let g:terminal_color_0 = '#4e4e4e'
  let g:terminal_color_1 = '#d68787'
  let g:terminal_color_2 = '#5f865f'
  let g:terminal_color_3 = '#d8af5f'
  let g:terminal_color_4 = '#85add4'
  let g:terminal_color_5 = '#d7afaf'
  let g:terminal_color_6 = '#87afaf'
  let g:terminal_color_7 = '#d0d0d0'
  let g:terminal_color_8 = '#626262'
  let g:terminal_color_9 = '#d75f87'
  let g:terminal_color_10 = '#87af87'
  let g:terminal_color_11 = '#ffd787'
  let g:terminal_color_12 = '#add4fb'
  let g:terminal_color_13 = '#ffafaf'
  let g:terminal_color_14 = '#87d7d7'
  let g:terminal_color_15 = '#e4e4e4'
else
  let g:terminal_ansi_colors = [
    \ '#4e4e4e', '#d68787', '#5f865f', '#d8af5f',
    \ '#85add4', '#d7afaf', '#87afaf', '#d0d0d0',
    \ '#626262', '#d75f87', '#87af87', '#ffd787',
    \ '#add4fb', '#ffafaf', '#87d7d7', '#e4e4e4'
  \ ]
endif
"}}}

" Shortcut Keys, Mappings ------------------------------------------------------ {{{

nnoremap ZX :qa<CR>
nnoremap <leader>ps :LoadLocalProjectSpecificSettings<cr>

nnoremap <leader>m :silent Make<cr>

noremap <leader>va :Git blame<CR>
noremap <leader>vr :Git blame --reverse<CR>
noremap gh :Git log --follow -- %<CR>

noremap <leader>y% :let @" = expand("%")<cr>

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
nnoremap <leader>evs :source $MYVIMRC<cr>

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

"{{{ Helper functions
function! StartsWith(longer, shorter) abort
  return a:longer[0:len(a:shorter)-1] ==# a:shorter
endfunction
"}}}

"{{{  Undotree toggle
nnoremap <leader>u :UndotreeToggle<CR>
"}}}

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


"{{{ Diff options
" Some interesting discussion on diffing algorithms
" https://stackoverflow.com/questions/32365271/whats-the-difference-between-git-diff-patience-and-git-diff-histogram/32367597#32367597
" The initial branch for mac is due to https://github.com/agude/dotfiles/issues/2
if has('mac') && $VIM == '/usr/share/vim'
    set diffopt-=internal
elseif has('nvim-0.3.2') || has("patch-8.1.0360")
    set diffopt=internal,algorithm:histogram,indent-heuristic
endif

" Turn off whitespaces compare and folding in vimdiff
set diffopt+=iwhite
set diffopt+=vertical

" Show filler lines, to keep the text synchronized with a window that has inserted lines at the same position
set diffopt+=filler
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
    set spelllang=en_au
endif

" Colours and Fonts ------------------------------------------------------------ {{{
syntax enable

if has("gui_running")
    set guitablabel=%M\ %t
endif


set termguicolors

let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'fugitive', 'filename', 'buffernumber'], [ 'mode', 'paste' ], [ 'cocstatus', 'readonly' ] ],
      \   'right': [ ['lineinfo'], ['percent'], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [ 'fugitive', 'filename', 'buffernumber'] ],
      \   'right': [ ['lineinfo'], ['percent'] ],
      \ },
      \ 'tabline': {
      \   'left': [ [ 'tabs' ] ], 'right': [ [ 'gitbranch', 'close' ] ],
      \ },
      \ 'tab': {
      \   'active': [ 'tabnum', 'filename', 'modified' ],
      \   'inactive': [ 'tabnum', 'filename', 'modified' ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'StatusFugitive',
      \   'filename': 'StatusFileName',
      \   'gitbranch': 'FugitiveHead',
      \   'mode': 'StatusFileMode',
      \   'cocstatus': 'coc#status',
      \ },
      \ 'component': {
      \   'buffernumber': '%n'
      \ }
      \ }
let g:lightline.enable = { 'statusline': 1, 'tabline': 1 }

function MySetColourScheme(colorscheme)
    let l:colorscheme = a:colorscheme
    if StartsWith(a:colorscheme, 'catppuccin') && has('nvim')
        let l:colorscheme = substitute(a:colorscheme, "_", "-", "")
    endif
    execute 'colorscheme ' . l:colorscheme
endfunction

if has('nvim')
    colorscheme catppuccin-latte
else
    colorscheme catppuccin_latte
endif
call lightline#update()

" This ensures lightline updates to match the colorscheme
autocmd ColorScheme * call s:UpdateLightlineColorScheme()

function s:UpdateLightlineColorScheme()
    let l:colorscheme = expand('<amatch>')
    if StartsWith(l:colorscheme, 'catppuccin') && has('nvim')
        " Catppuccin for NeoVim has just the "catppuccin" colorscheme
        let l:colorscheme = 'catppuccin'
    endif
    let g:lightline.colorscheme = l:colorscheme
    call lightline#disable()
    call lightline#enable()
endfunction

highlight Comment cterm=italic gui=italic

" Mode is not necessary with lightline as mode is shown on the left
set noshowmode

hi MatchParen ctermbg=blue guibg=lightblue
"}}}

" Map double Ctrl-K in insert mode to search digraph names
" Run :helptags ~/.vim/doc to generate docs
imap <C-K><C-K> <Plug>(DigraphSearch)

" ClangFormat ----------------------------------------------------------- {{{

if ! has('nvim')
    " Formatting selected code. Note: these are overridden by clangd usage in coc.vim section
    autocmd FileType cpp nnoremap <buffer> <leader>f :ClangFormat<cr>
    autocmd FileType cpp nnoremap <buffer> <C-A-l> :ClangFormat<cr>
    autocmd FileType cpp xnoremap <buffer> <leader>f :ClangFormat<cr>
    autocmd FileType starlark,bzl,python nnoremap <buffer> <leader>f <Plug>(ale_fix)
    autocmd FileType starlark,bzl,python nnoremap <silent> [g <Plug>(ale_previous_wrap)
    autocmd FileType starlark,bzl,python nnoremap <silent> ]g <Plug>(ale_next_wrap)
    autocmd FileType starlark,bzl,python nnoremap <silent> K <Plug>(ale_hover)
    "autocmd FileType starlark,bzl,python nnomap <leader>qf  <Plug>(coc-fix-current)
endif

"}}}

function! LoadLocalConfigs()
    " Load any local .vim.local files
    if filereadable(glob("~/.vimrc.local"))
        source ~/.vimrc.local
    endif

    " Load any .vim files in ~/.vim/local. (Ignore .plugged.vim as they are
    " loaded above)
    let s:old_wildignore = &wildignore
    set wildignore=*.plugged.vim
    let s:local_config_files = globpath(s:local_config_files_dir, '**/*.vim', 0, 1)
    let &wildignore = s:old_wildignore
    for s:config_file in s:local_config_files
        execute 'source' s:config_file
    endfor
endfunction

call LoadLocalConfigs()

call s:LoadProjectSpecificSettings()

" First tab completes as much as possible; second provides a list; third
" starts cyclying through the options
set wildmode=longest,list,full
set wildmenu

if exists("&wildignorecase")
    set wildignorecase
endif

" Helper Functions ------------------------------------------------------------- {{{

nmap <leader>; <Plug>(ToggleSemicolonAtEnd)   " toggle semicolon at end of line

let g:ctags_statusline=1

" Don't display splash screen on start
set shortmess+=I

" Configuration to keep edits safe --------------------------------------------- {{{

function s:CreateDirIfMissing(dir_path)
    let target_path = expand(a:dir_path)
    if !isdirectory(target_path)
        echo "Created " . l:target_path . " directory"
        call mkdir(target_path, "p", 0700)
    endif
    return l:target_path
endfunction

" Protect changes between writes. Default values of updatecount (200 keystrokes)
" and updatetime (4 seconds) are fine
set swapfile
let swap_target_path = s:CreateDirIfMissing('~/.vim/swap')
set directory^=~/.vim/swap//

" protect against crash-during-write
set writebackup
" but do not persist backup after successful write
set nobackup
" use rename-and-write-new method whenever safe
set backupcopy=auto
" patch required to honor double slash at end
" consolidate the writebackups -- not a big
" deal either way, since they usually get deleted
let backup_target_path = s:CreateDirIfMissing('~/.vim/backup')
set backupdir^=~/.vim/backup//

if has("persistent_undo")
    if !has('nvim')
        let &undodir=s:CreateDirIfMissing('~/.vim/undodir')
    endif
    set undofile
endif

"}}}


if ! has('nvim')

    let g:coc_global_extensions=['coc-json', 'coc-diagnostic', 'coc-clangd', 'coc-sh']

    " Use :call UseCocShortcuts() to enable COC usage
    function s:UseCocShortcuts()
        if !exists('g:did_coc_loaded')
            return
        endif

        if has("nvim-0.5.0") || has("patch-8.1.1564")
        " Recently vim can merge signcolumn and number column into one
        set signcolumn=number
        else
        set signcolumn=yes
        endif

        " Use tab for trigger completion with characters ahead and navigate
        " NOTE: There's always complete item selected by default, you may want to enable
        " no select by `"suggest.noselect": true` in your configuration file
        " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
        " other plugin before putting this into your config
        "inoremap <silent><expr> <TAB>
            "\ coc#pum#visible() ? coc#pum#next(1) :
            "\ CheckBackspace() ? "\<Tab>" :
            "\ coc#refresh()
        "inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

        function! CheckBackspace() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~# '\s'
        endfunction


        " Use `[g` and `]g` to navigate diagnostics
        " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
        let ale_enabled = get(g:, 'ale_enabled', 0)
        if (ale_enabled)
            nmap <silent> [g <Plug>(ale_previous_wrap)
            nmap <silent> ]g <Plug>(ale_next_wrap)
        else
            nmap <silent> [g <Plug>(coc-diagnostic-prev)
            nmap <silent> ]g <Plug>(coc-diagnostic-next)
        endif
        " Make <CR> to accept selected completion item or notify coc.nvim to format
        " <C-g>u breaks current undo, please make your own choice
        inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                    \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

        " GoTo code navigation.
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> <C-w>gd :call CocAction('jumpDefinition', 'vsplit')<CR>
        nmap <silent> <C-w>ge :call CocAction('definitions', 'vsplit')<CR>
        nmap <silent> <C-w>gc :call CocAction('jumpDeclaration', 'vsplit')<CR>
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> <C-w>gy :call CocAction('jumpTypeDefinition', 'vsplit')<CR>
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> <C-w>gi :call CocAction('implementations', 'vsplit')<CR>
        nmap <silent> gr <Plug>(coc-references)
        nmap <silent> <C-w>gr :call CocAction('references', 'vsplit')<CR>

        " Use K to show documentation in preview window.
        nnoremap <silent> K :call ShowDocumentation()<CR>
        inoremap <silent> <C-P> <C-\><C-O>:call CocActionAsync('showSignatureHelp')<cr>

        function! ShowDocumentation()
        if CocAction('hasProvider', 'hover')
            call CocActionAsync('doHover')
        else
            call feedkeys('K', 'in')
        endif
        endfunction

        command! -nargs=0 SwitchSourceHeader   :call     CocActionAsync('runCommand', 'clangd.switchSourceHeader')
        " Overrides default above
        nnoremap <leader>s :SwitchSourceHeader<CR>

        " Highlight the symbol and its references when holding the cursor.
        autocmd CursorHold * silent call CocActionAsync('highlight')

        " Symbol renaming.
        nmap <leader>rn <Plug>(coc-rename)

        " Formatting selected code. Note: these override basic ClangFormat bindings above
        nnoremap <leader>f  <Plug>(coc-format)
        nnoremap <C-A-l> <Plug>(coc-format)
        xnoremap <leader>f  <Plug>(coc-format-selected)

        augroup mygroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder.
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        augroup end

        " Applying codeAction to the selected region.
        " Example: `<leader>aap` for current paragraph
        xmap <leader>a  <Plug>(coc-codeaction-selected)
        nmap <leader>a  <Plug>(coc-codeaction-selected)

        " Remap keys for applying codeAction to the current buffer.
        nmap <leader>ac  <Plug>(coc-codeaction)
        " Apply AutoFix to problem on the current line.
        nmap <leader>.  <Plug>(coc-fix-current)

        " Run the Code Lens action on the current line.
        nmap <leader>cl  <Plug>(coc-codelens-action)

        " Map function and class text objects
        " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
        xmap if <Plug>(coc-funcobj-i)
        omap if <Plug>(coc-funcobj-i)
        xmap af <Plug>(coc-funcobj-a)
        omap af <Plug>(coc-funcobj-a)
        xmap ic <Plug>(coc-classobj-i)
        omap ic <Plug>(coc-classobj-i)
        xmap ac <Plug>(coc-classobj-a)
        omap ac <Plug>(coc-classobj-a)

        inoremap <expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<CR>"

        " Remap <C-f> and <C-b> for scroll float windows/popups.
        if has('nvim-0.4.0') || has('patch-8.2.0750')
        nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
        inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
        vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        endif

        " Use CTRL-S for selections ranges.
        " Requires 'textDocument/selectionRange' support of language server.
        nmap <silent> <C-s> <Plug>(coc-range-select)
        xmap <silent> <C-s> <Plug>(coc-range-select)

        " Add `:Format` command to format current buffer.
        command! -nargs=0 Format :call CocActionAsync('format')

        " Add `:Fold` command to fold current buffer.
        command! -nargs=? Fold :call     CocAction('fold', <f-args>)

        " Add `:OR` command for organize imports of the current buffer.
        command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

        " Add (Neo)Vim's native statusline support.
        " NOTE: Please see `:h coc-status` for integrations with external plugins that
        " provide custom statusline: lightline.vim, vim-airline.
        "set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

        " Use autocmd to force lightline update.
        autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

        " Mappings for CoCList
        " Show all diagnostics.
        nnoremap <silent><nowait> <space>a  :<C-u>CocList -A diagnostics<cr>
        " Manage extensions.
        nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
        " Show commands.
        nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
        " Find symbol of current document.
        nnoremap <silent><nowait> <space>o  :<C-u>CocList -A outline<cr>
        nnoremap <silent><nowait> <F4>  :<C-u>CocOutline<cr>
        " Search workspace symbols.
        nnoremap <silent><nowait> <space>s  :<C-u>CocList -I -A symbols<cr>
        nnoremap <silent><nowait> <space>S  :<C-u>CocList -I -A --tab symbols<cr>
        " Do default action for next item.
        nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
        " Do default action for previous item.
        nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
        " Resume latest coc list.
        nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
    endfunction

    com! UseCocShortcuts call s:UseCocShortcuts()
endif

" vim:fdm=marker
