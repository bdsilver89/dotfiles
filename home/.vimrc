set nocompatible
scriptencoding utf-8

" =============================================================================
" Encoding and file formats
" =============================================================================
set encoding=utf-8 fileencodings=utf-8,latin1 fileformats=unix,dos
set hidden autoread confirm swapfile updatetime=300
set nobackup writebackup nomodeline nowriteany

" =============================================================================
" State directories
" =============================================================================
if exists('*mkdir') && exists('*isdirectory')
    let s:state_dir = expand('~/.vim/state')
    let s:swap_dir = s:state_dir . '/swap'
    let s:undo_dir = s:state_dir . '/undo'
    let s:backup_dir = s:state_dir . '/backup'

    for s:dir in [s:swap_dir, s:undo_dir, s:backup_dir]
        if !isdirectory(s:dir)
            silent! call mkdir(s:dir, 'p')
        endif
    endfor

    if isdirectory(s:swap_dir) && exists('+directory')
        let &directory = s:swap_dir . '//'
    endif
    if isdirectory(s:backup_dir) && exists('+backupdir')
        let &backupdir = s:backup_dir . '//'
    endif
    if has('persistent_undo') && isdirectory(s:undo_dir)
        if exists('+undodir')
            let &undodir = s:undo_dir . '//'
        endif
        set undofile
    endif
endif

" =============================================================================
" Editing behavior
" =============================================================================
set backspace=indent,eol,start history=1000 undolevels=1000
set expandtab tabstop=4 softtabstop=4 shiftwidth=4 shiftround
set autoindent nosmartindent nocindent
set nowrap scrolloff=8 sidescrolloff=8

if exists('+linebreak') | set linebreak | endif
if exists('+breakindent') | set breakindent | endif

set ttimeout ttimeoutlen=50 mouse=nvi

" =============================================================================
" Search
" =============================================================================
set incsearch hlsearch ignorecase smartcase magic

if exists('+inccommand')
    set inccommand=split
endif

" =============================================================================
" Command-line completion
" =============================================================================
set wildmenu wildmode=longest:full,full

" =============================================================================
" UI
" =============================================================================
set number relativenumber ruler showcmd showmode laststatus=2
set cursorline list listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:+
set splitbelow splitright lazyredraw pumheight=10

if exists('+signcolumn')
    set signcolumn=yes
endif

if exists('+belloff')
    set belloff=all
else
    set noerrorbells visualbell
endif

" =============================================================================
" Colors
" =============================================================================
set background=dark

if exists('+termguicolors') && (has('gui_running') || $COLORTERM =~? 'truecolor\|24bit')
    set termguicolors

    if &term =~# '256color' || &term =~# 'tmux'
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
endif

if has('syntax')
    syntax enable
endif

silent! colorscheme default

" =============================================================================
" Clipboard
" =============================================================================
if has('clipboard') && exists('+clipboard')
    if has('unnamedplus')
        set clipboard^=unnamedplus
    elseif has('gui_macvim')
        set clipboard^=unnamed
    endif
endif

" =============================================================================
" External CLI tools
" =============================================================================
if executable('rg') && exists('+grepprg')
    set grepprg=rg\ --vimgrep\ --smart-case

    if exists('+grepformat')
        set grepformat=%f:%l:%c:%m
    endif
endif

" =============================================================================
" Filetype Support
" =============================================================================
if has('autocmd')
    filetype plugin indent on
endif

" =============================================================================
" Netrw
" =============================================================================
let g:netrw_banner = 0
let g:netrw_liststyle = 0
let g:netrw_browse_split = 0

" =============================================================================
" Keymaps
" =============================================================================
let mapleader = ' '
let maplocalleader = ','

nnoremap <silent><expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <silent><expr> <Down> v:count == 0 ? 'gj' : 'j'
nnoremap <silent><expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <silent><expr> <Up> v:count == 0 ? 'gk' : 'k'

nnoremap <silent> <C-d> <C-d>zz
nnoremap <silent> <C-u> <C-u>zz
nnoremap <silent> N Nzzzv
nnoremap <silent> n nzzzv

nnoremap <silent> <leader>- <C-w>s
nnoremap <silent> <leader><Bar> <C-w>v
nnoremap <silent> <leader>q :quit<CR>
nnoremap <silent> <leader>w :write<CR>
nnoremap <silent> <leader>bd :bd<CR>

nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <silent><expr> - :Ex<CR>

xnoremap < <gv
xnoremap > >gv

if exists(':tnoremap') == 2
    tnoremap <silent> <Esc><Esc> <C-\><C-n>
endif

function! s:ToggleQuickfix() abort
    let l:window_count = winnr('$')
    silent! cclose

    if winnr('$') == l:window_count
        silent! copen
    endif
endfunction

function! s:ToggleLocationList() abort
    let l:window_count = winnr('$')
    silent! lclose

    if winnr('$') == l:window_count
        silent! lopen
    endif
endfunction

nnoremap <silent> <leader>xq :call <SID>ToggleQuickfix()<CR>
nnoremap <silent> <leader>xl :call <SID>ToggleLocationList()<CR>

" =============================================================================
" Autocmds
" =============================================================================
if has('autocmd')
    augroup config
        autocmd!

        if exists('##FocusGained')
            autocmd FocusGained * silent! checktime
        endif
        if exists('##VimResized')
            autocmd VimResized * silent! wincmd =
        endif

        autocmd FileType make setlocal noexpandtab
        autocmd FileType gitcommit,markdown,text setlocal wrap linebreak
    augroup END
endif

" =============================================================================
" Plugins
" =============================================================================
let s:has_vim_plug = 0
if exists('*globpath')
    let s:has_vim_plug = !empty(globpath(&runtimepath, 'autoload/plug.vim'))
endif

let s:has_builtin_editorconfig = 0
if has('patch-9.0.1799') && exists(':packadd') == 2 && exists('*globpath')
    let s:has_builtin_editorconfig =
                \ !empty(globpath(&packpath, 'pack/*/opt/editorconfig'))
    if s:has_builtin_editorconfig
        packadd! editorconfig
    endif
endif

if s:has_vim_plug
    set loadplugins
else
    set noloadplugins
endif

if s:has_vim_plug
    call plug#begin(expand('~/.vim/plugged'))

    let g:lightline = { 'colorscheme': 'catppuccin' }

    " Current plugin releases target modern Vim. Vim 7 keeps core config only.
    if v:version >= 800
        if !s:has_builtin_editorconfig
            Plug 'editorconfig/editorconfig-vim'
        endif
        Plug 'catppuccin/vim', { 'as': 'catppuccin' }
        Plug 'Yggdroot/indentLine'
        " Plug 'vim-airline/vim-airline'
        Plug 'itchyny/lightline.vim'
        Plug 'machakann/vim-highlightedyank'

        Plug 'mbbill/undotree'
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-surround'
        Plug 'tpope/vim-dispatch'
        Plug 'tpope/vim-sleuth'
        Plug 'tpope/vim-unimpaired'
        Plug 'tpope/vim-vinegar'

        Plug 'tpope/vim-fugitive'
        Plug 'airblade/vim-gitgutter'

        Plug 'christoomey/vim-tmux-navigator'
        Plug 'junegunn/fzf'
        Plug 'junegunn/fzf.vim'

        Plug 'vim-polyglot/vim-polyglot'
        Plug 'dense-analysis/ale'
        Plug 'vim-test/vim-test'
    endif

    call plug#end()

    function! s:PluginInstalled(name) abort
        return exists('g:plugs')
                    \ && has_key(g:plugs, a:name)
                    \ && isdirectory(g:plugs[a:name].dir)
    endfunction

    if exists('*globpath')
                \ && !empty(globpath(&runtimepath, 'colors/catppuccin_mocha.vim'))
        colorscheme catppuccin_mocha
    endif

    if s:PluginInstalled('fzf.vim')
        nnoremap <silent> <leader>sf :Files<CR>
        nnoremap <silent> <leader>sg :Rg<CR>
        nnoremap <silent> <leader>sb :Buffers<CR>
    endif
    if s:PluginInstalled('vim-fugitive')
        nnoremap <silent> <leader>gs :Git<CR>
    endif
    if s:PluginInstalled('vim-vinegar')
        nmap <silent> - <Plug>VinegarUp
    endif
endif

let s:has_ale = s:has_vim_plug && s:PluginInstalled('ale')
if s:has_ale
    let g:ale_completion_enabled = 1
    let g:ale_fix_on_save = 1
    let g:ale_linters_explicit = 1
    let g:ale_linters = {
                \ 'c': ['clangd'],
                \ 'cpp': ['clangd'],
                \ 'java': ['eclipselsp'],
                \ 'python': ['pyright'],
                \ 'rust': ['analyzer'],
                \ }
    let g:ale_fixers = {
                \ 'c': ['clang-format'],
                \ 'cpp': ['clang-format'],
                \ 'java': ['google_java_format'],
                \ 'python': ['black'],
                \ 'rust': ['rustfmt'],
                \ }
    set completeopt=menu,menuone,noselect,noinsert

    inoremap <silent><expr> <Tab>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>CheckBackspace() ? "\<Tab>" :
        \ "\<C-x>\<C-o>"
    inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"
    inoremap <silent><expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

    function! s:CheckBackspace() abort
        let l:column = col('.') - 1
        return !l:column || getline('.')[l:column - 1] =~# '\s'
    endfunction

    function! s:ToggleAleFixOnSave() abort
        let g:ale_fix_on_save = !get(g:, 'ale_fix_on_save', 0)
        echo 'ALE fix on save ' . (g:ale_fix_on_save ? 'enabled' : 'disabled')
    endfunction

    nnoremap <silent> K :call <SID>ShowDocumentation()<CR>

    function! s:ShowDocumentation() abort
        if index(['vim', 'help'], &filetype) >= 0
            execute 'help ' . expand('<cword>')
        elseif exists(':ALEHover') == 2
            ALEHover
        else
            execute '!' . &keywordprg . ' ' . shellescape(expand('<cword>'))
        endif
    endfunction

    nmap <silent> gd  <Plug>(ale_go_to_definition)
    nmap <silent> gri <Plug>(ale_go_to_implementation)
    nnoremap <silent> grn :ALERename<CR>
    nmap <silent> grr <Plug>(ale_find_references)
    nmap <silent> grt <Plug>(ale_go_to_type_definition)
    nnoremap <silent> gra :ALECodeAction<CR>
    xnoremap <silent> gra :ALECodeAction<CR>

    nmap <silent> [d <Plug>(ale_previous_wrap)
    nmap <silent> ]d <Plug>(ale_next_wrap)

    nmap <leader>f <Plug>(ale_fix)
    nnoremap <silent> <leader>uf :call <SID>ToggleAleFixOnSave()<CR>
endif
