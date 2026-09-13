set nocompatible
scriptencoding utf-8

" =============================================================================
" Helpers
" =============================================================================
function! s:Enable(name) abort
    if exists('+' . a:name)
        execute 'set ' . a:name
    endif
endfunction

function! s:Disable(name) abort
    if exists('+' . a:name)
        execute 'set no' . a:name
    endif
endfunction

function! s:Set(name, value) abort
    if exists('+' . a:name)
        execute 'let &' . a:name . ' = ' . string(a:value)
    endif
endfunction

" =============================================================================
" Encoding and file formats
" =============================================================================
call s:Enable('hidden')
call s:Enable('autoread')
call s:Enable('confirm')
call s:Enable('swapfile')
call s:Set('updatetime', 300)
call s:Disable('backup')
call s:Disable('writebackup')
call s:Disable('modeline')
call s:Disable('writeany')

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
    if isdirectory(s:backup_dir) && exists('+directory')
        let &directory = s:backup_dir . '//'
    endif
    if has('persistent_undo') && isdirectory(s:undo_dir)
        if exists('+undodir')
            let &undodir = s:undo_dir . '//'
        endif
        call s:Enable('undofile')
    endif
endif

" =============================================================================
" Editing behavior
" =============================================================================
call s:Set('backspace', 'indent,eol,start')
call s:Set('history', 1000)
call s:Set('undolevels', 1000)

call s:Enable('expandtab')
call s:Set('tabstop', 4)
call s:Set('softtabstop', 4)
call s:Set('shiftwidth', 4)
call s:Enable('shiftround')

call s:Enable('autoindent')
call s:Disable('smartindent')
call s:Disable('cindent')

call s:Disable('wrap')
call s:Enable('linebreak')
call s:Enable('breakindent')

call s:Set('scrolloff', 8)
call s:Set('sidescrolloff', 8)

call s:Enable('ttimeout')
call s:Set('tttimeoutlen', 50)

call s:Set('mouse', 'nvi')

" =============================================================================
" Search
" =============================================================================
call s:Enable('incsearch')
call s:Enable('hlsearch')
call s:Enable('ignorecase')
call s:Enable('smartcase')
call s:Enable('magic')
call s:Set('path', '.,,**')

if exists('+inccommand')
    call s:Set('inccommand', 'split')
endif

" =============================================================================
" Command-line completion
" =============================================================================
call s:Enable('wildmenu')
call s:Set('wildmode', 'longest:full,full')

" =============================================================================
" UI
" =============================================================================
call s:Enable('number')
call s:Enable('relativenumber')
call s:Enable('ruler')
call s:Enable('showcmd')
call s:Enable('showmode')
call s:Set('laststatus', 2)
call s:Enable('cursorline')
call s:Set('signcolumn', 'yes')
call s:Enable('list')
call s:Set('listchars', 'tab:>-,trail:-,extends:>,precedes:<,nbsp:+')
call s:Enable('splitbelow')
call s:Enable('splitright')
call s:Enable('lazyredraw')
call s:Set('belloff', 'all')
call s:Disable('errorbells')
call s:Enable('visualbell')

" =============================================================================
" Colors
" =============================================================================
call s:Set('background', 'dark')

if exists('+termguicolors') && (has('gui_running') || $COLORTERM =~? 'truecolor\|24bit')
    set termguicolors
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
" Keymaps
" =============================================================================
let mapleader = ' '
let maplocalleader = ','

nnoremap <silent> <leader>w :write<CR>
nnoremap <silent> <leader>q :quit<CR>

nnoremap <silent> <Esc> :nohlsearch<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

xnoremap < <gv
xnoremap > >gv

" =============================================================================
" Autocmds
" =============================================================================
if has('autocmd')
    augroup config
        autocmd!

        if exists('##FocusGained')
            autocmd FocusGained * silent! checktime
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

if s:has_vim_plug
    call plug#begin(expand('~/.vim/plugged'))

    Plug 'catppuccin/vim', { 'as': 'catppuccin' }
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-dispatch'
    Plug 'tpope/vim-sleuth'
    Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'
    Plug 'christoomey/vim-tmux-navigator'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'neoclide/coc.nvim', { 'branch': 'release' }

    call plug#end()

    silent! colorscheme catppuccin_mocha

    nnoremap <silent> <leader>sf :Files<CR>
    nnoremap <silent> <leader>gs :Git<CR>

    nnoremap <silent> <leader>e :NERDTreeToggle<CR>

    inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1) :
        \ CheckBackspace() ? "\<Tab>" :
        \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
        \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"


    function! CheckBackspace() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    nnoremap <silent> K :call ShowDocumentation()\<CR>

    function! ShowDocumentation()
    if index(['vim','help'], &filetype) >= 0
        execute 'h '.expand('<cword>')
    elseif coc#rpc#ready()
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . " " . expand('<cword>')
    endif
    endfunction

    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    nmap <leader>rn <Plug>(coc-rename)

    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    autocmd CursorHold * silent call CocActionAsync('highlight')
endif

" =============================================================================
" Cleanup
" =============================================================================
unlet! s:has_vim_plug
unlet! s:state_dir
unlet! s:swap_dir
unlet! s:undo_dir
unlet! s:backup_dir
