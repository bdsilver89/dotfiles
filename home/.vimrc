" =============================================================================
" Options
" =============================================================================





set nocompatible

if has("multi_byte")
    set encoding=utf-8
    set fileencodings=ucs-bom,utf-8,latin1
endif

filetype plugin indent on

if has("syntax")
    syntax on
endif

set number
set relativenumber
set showcmd
set ruler
set backspace=indent,eol,start

if has("syntax")
    set cursorline
endif

if has("wildmenu")
    set wildmenu
    set wildmode=longest:full,full
endif

if exists("+wildignorecase")
    set wildignorecase
endif

set path=**

set ignorecase
set smartcase

if has("extra_search")
    set hlsearch
    set incsearch
endif

set autoindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set history=1000
set undolevels=1000
set nobackup
set lazyredraw

if exists("*mkdir") && !isdirectory(expand("~/.vim/swap"))
    silent! call mkdir(expand("~/.vim/swap"), "p", 0700)
endif

if isdirectory(expand("~/.vim/swap"))
    set directory=~/.vim/swap//,.
endif

set noerrorbells
set novisualbell

set laststatus=2

if has("termguicolors") && $COLORTERM =~# 'truecolor\|24bit'
    set termguicolors
elseif &term =~? '256color\|kitty\|alacritty\|foot\|wezterm'
    set t_Co=256
endif

set hidden
set autoread
set scrolloff=3
set sidescrolloff=5
set splitbelow
set splitright
set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
set ttimeout
set ttimeoutlen=100

if v:version > 703
    set formatoptions+=j
endif

" =============================================================================
" Grep
" =============================================================================
set grepprg=grep\ -RIn\ --exclude-dir=.git\ $*\ /dev/null

command! -nargs=+ Grep silent grep! <args> | cwindow | redraw!

" =============================================================================
" Keymaps
" =============================================================================

let mapleader = " "

nnoremap <esc><esc> :noh<CR>

nnoremap <leader>/ :Grep<space>
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap ]Q :clast<CR>
nnoremap [Q :cfirst<CR>
