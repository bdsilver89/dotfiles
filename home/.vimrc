" Minimal Vim configuration. The terminal provides the color palette.
set nocompatible
scriptencoding utf-8

let mapleader = ' '
let maplocalleader = ','

set encoding=utf-8
set hidden
set autoread
set backspace=indent,eol,start

set number
set relativenumber
set cursorline
set nowrap
set scrolloff=5
set sidescrolloff=5
set signcolumn=yes

set splitbelow
set splitright
set ignorecase
set smartcase
set incsearch
set hlsearch
set wildmenu
set wildignorecase
set wildmode=longest:full,full
set showcmd
set showmode
set ruler
set laststatus=2

set mouse=a
set pumheight=10
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

set list
set listchars=tab:»·,trail:·,extends:›,precedes:‹,nbsp:+
set updatetime=300

if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat=%f:%l:%c:%m
endif

if has('unnamedplus')
    set clipboard=unnamedplus
elseif has('clipboard')
    set clipboard=unnamed
endif

let s:state_root = expand('~/.vim/state')
for s:directory in ['undo', 'swap', 'backup']
    call mkdir(s:state_root . '/' . s:directory, 'p', 0700)
endfor
execute 'set undodir=' . fnameescape(s:state_root . '/undo//')
execute 'set directory=' . fnameescape(s:state_root . '/swap//')
execute 'set backupdir=' . fnameescape(s:state_root . '/backup//')
set undofile
set backup
set nowritebackup

filetype plugin indent on
syntax on

nnoremap <silent> <C-d> <C-d>zz
nnoremap <silent> <C-u> <C-u>zz
nnoremap <silent> n nzzzv
nnoremap <silent> N Nzzzv
nnoremap <silent> <Esc> :nohlsearch<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <silent> <leader>- :split<CR>
nnoremap <silent> <leader><Bar> :vsplit<CR>

if has('terminal')
    tnoremap <Esc><Esc> <C-\><C-n>
endif
