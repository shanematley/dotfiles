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
call plug#begin()
Plug 'airblade/vim-gitgutter'
Plug 'altercation/vim-colors-solarized'
Plug 'preservim/vimux'
Plug 'google/vim-maktaba' " For vim-bazel. Must be before it.
Plug 'bazelbuild/vim-bazel'
Plug 'cappyzawa/starlark.vim'
"Plug 'ervandew/supertab' " Use tab for insert completion
Plug 'Glench/Vim-Jinja2-Syntax'
"Plug 'gmarik/Vundle.vim'
"Plug 'godlygeek/csapprox'
"Plug 'godlygeek/tabular'
Plug 'https://shanematley@bitbucket.org/shanematley/cppguards.git'
Plug 'itchyny/lightline.vim'
Plug 'justinmk/vim-sneak' " s followed by two characters
"Plug 'justinmk/vim-syntax-extra'
"Plug 'kana/vim-scratch'
"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'majutsushi/tagbar', { 'on' : 'TagbarOpenAutoClose' }
"Plug 'mileszs/ack.vim'
Plug 'moll/vim-bbye'  " Close buffers with Bdelete|Bwipeout without ruining window setup
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Installing for C++:
" :CocInstall coc-clangd
" Create compile_commands.json by cloning the following repo and running the
" generate.py script when in bazel directory. https://github.com/grailbio/bazel-compilation-database
Plug 'NLKNguyen/papercolor-theme'
Plug 'ojroques/vim-oscyank'
Plug 'PeterRincker/vim-argumentative' " Shift arguments with <, >, Move between argument boundaries with [, ], New text objects a, i,
Plug 'rhysd/vim-clang-format', {'on': 'ClangFormat'}
Plug 'richq/cmakecompletion-vim', {'for' : 'cmake' } " C-X C-O for completion of cmake;  K mapping for help
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Shirk/vim-gas', { 'for' : 'gas' } " Syntax highlighting for GNU as
"Plug 'sjl/gundo.vim'
Plug 'mbbill/undotree'
Plug 'tommcdo/vim-exchange' " cx or cxx or X (visual mode) to exchange. cxc to clear
Plug 'tpope/vim-abolish' " Replacement with variations: :%Subvert/facilit{y,ies}/building{,s}/g
                         " Also: Press crs (coerce to snake_case). MixedCase (crm), camelCase (crc),
                         " snake_case (crs), UPPER_CASE (cru), dash-case (cr-), dot.case (cr.),
                         " space case (cr<space>), and Title Case (crt)
Plug 'tpope/vim-characterize' " Additional info with (ga) for character
Plug 'tpope/vim-dispatch', { 'on' : ['Make', 'Start', 'Dispatch', 'FocusDispatch', 'Copen'] }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-projectionist' " A number of things, but includes :A, :AS, :AV, and :AT to jump to an 'alternate' file
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired' " [q/|]q for cprev|cnext; yos toggle spell; yon toggle numbers; [n|]n jump between conflict markers;
                            " [f|]f next/previous file in directory; yow toggle wrap
Plug 'vim-scripts/a.vim' " Switch header/source with :A and <leader>-s/S
Plug 'vim-scripts/genutils'
Plug 'vim-scripts/vim-indent-object' " ai, ii, aI, iI (an/inner indentation level and line above/below)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'luochen1990/rainbow'
call plug#end()
"}}}

autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | execute 'OSCYankReg +' | endif

nnoremap <silent> <C-t> :Files<CR>
" C-/
nnoremap <silent> <leader>hh :History<CR>
nnoremap <silent> <leader>h/ :History/<CR>
nnoremap <silent> <leader>h; :History:<CR>
nnoremap <silent> <leader>ll :Lines<CR>
nnoremap <silent> <leader>lb :BLines<CR>
nnoremap <silent> <leader>g :Rg<CR>
nnoremap <leader>q :Rg <C-r><C-w><CR>
nnoremap <leader>Q :Rg \b<C-r><C-w>\b<CR>
nnoremap <silent> <leader>U :GitGutterUndoHunk<CR>

nnoremap <silent> <F2> :call CocAction('diagnosticNext')<cr>
nnoremap <silent> <S-F2> :call CocAction('diagnosticPrevious')<cr>

let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

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
nnoremap <leader>r :NERDTreeFind<cr>
nnoremap <leader>n :NERDTreeToggle<cr>
let NERDTreeIgnore=['\.pyc$', '\~$']
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
        colorscheme powerline
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

" Shortcut Keys, Mappings ------------------------------------------------------ {{{

nnoremap ZX :qa<CR>
nnoremap <leader>b :Buffers<cr>
nnoremap <leader>t :GFiles<cr>
nnoremap <leader>ps :LoadLocalProjectSpecificSettings<cr>

nnoremap <leader>m :silent Make<cr>

noremap <leader>va :Git blame<CR>
noremap <leader>vr :Git blame --reverse<CR>
noremap gh :Git log -- %<CR>

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

"{{{  Undotree toggle
nnoremap <leader>u :UndotreeToggle<CR>

if has("persistent_undo")
   let target_path = expand('~/.undodir')

    " create the directory and any parent directories
    " if the location does not exist.
    if !isdirectory(target_path)
        call mkdir(target_path, "p", 0700)
    endif

    let &undodir=target_path
    set undofile
endif
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
    set t_Co=256
    set guitablabel=%M\ %t
endif

set background=dark
colorscheme PaperColor
highlight Comment cterm=italic gui=italic

" Mode is not necessary with lightline as mode is shown on the left
set noshowmode

hi MatchParen ctermbg=blue guibg=lightblue
"}}}

" Insert digraphs by typing the letters then C-n rather than the normal
" way of entering diagraph mode with C-k and typing the two keys.
imap <C-n> <Plug>(DigraphFromPrevChars)

" Map double Ctrl-K in insert mode to search digraph names
" Run :helptags ~/.vim/doc to generate docs
imap <C-K><C-K> <Plug>(DigraphSearch)

" ClangFormat ----------------------------------------------------------- {{{

noremap <leader>cf :ClangFormat<cr>
vnoremap <leader>cf :ClangFormat<cr>

"}}}

" Load any local .vim.local files
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif
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

" Protect changes between writes. Default values of
" updatecount (200 keystrokes) and updatetime
" (4 seconds) are fine
set swapfile
set directory^=~/.vim/swap//

" protect against crash-during-write
set writebackup
" but do not persist backup after successful write
set nobackup
" use rename-and-write-new method whenever safe
set backupcopy=auto
" patch required to honor double slash at end
if has("patch-8.1.0251")
    " consolidate the writebackups -- not a big
    " deal either way, since they usually get deleted
    set backupdir^=~/.vim/backup//
end

" persist the undo tree for each file
set undofile
set undodir^=~/.vim/undo//

"}}}

" Use :call UseCocShortcuts() to enable COC usage
function UseCocShortcuts()
    if !exists('g:did_coc_loaded')
        return
    endif

    if has("nvim-0.5.0") || has("patch-8.1.1564")
    " Recently vim can merge signcolumn and number column into one
    set signcolumn=number
    else
    set signcolumn=yes
    endif
    inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ CheckBackspace() ? "\<TAB>" :
        \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " GoTo code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Use K to show documentation in preview window.
    nnoremap <silent> K :call ShowDocumentation()<CR>

    function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'in')
    endif
    endfunction

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Symbol renaming.
    nmap <leader>rn <Plug>(coc-rename)

    " Formatting selected code.
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

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
    nmap <leader>qf  <Plug>(coc-fix-current)

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
    set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

    " Mappings for CoCList
    " Show all diagnostics.
    nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
    " Manage extensions.
    nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
    " Show commands.
    nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
    " Find symbol of current document.
    nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
    " Search workspace symbols.
    nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
    " Do default action for next item.
    nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
    " Do default action for previous item.
    nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
    " Resume latest coc list.
    nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
endfunction

" vim:fdm=marker
