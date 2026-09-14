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
call s:Set('encoding', 'utf-8')
call s:Set('fileencodings', 'utf-8,latin1')
call s:Set('fileformats', 'unix,dos')

call s:Enable('hidden')
call s:Enable('autoread')
call s:Enable('confirm')
call s:Enable('swapfile')
call s:Set('updatetime', 300)
call s:Disable('backup')
call s:Enable('writebackup')
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
    if isdirectory(s:backup_dir) && exists('+backupdir')
        let &backupdir = s:backup_dir . '//'
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
call s:Set('ttimeoutlen', 50)

call s:Set('mouse', 'nvi')

" =============================================================================
" Search
" =============================================================================
call s:Enable('incsearch')
call s:Enable('hlsearch')
call s:Enable('ignorecase')
call s:Enable('smartcase')
call s:Enable('magic')

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
if exists('+belloff')
    call s:Set('belloff', 'all')
else
    call s:Disable('errorbells')
    call s:Enable('visualbell')
endif
call s:Set('pumheight', 10)

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

nnoremap <silent> <Esc> :nohlsearch<CR>

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
    call s:Enable('loadplugins')
else
    call s:Disable('loadplugins')
endif

if s:has_vim_plug
    call plug#begin(expand('~/.vim/plugged'))

    " Current plugin releases target modern Vim. Vim 7 keeps core config only.
    if v:version >= 800
        if !s:has_builtin_editorconfig
            Plug 'editorconfig/editorconfig-vim'
        endif
        Plug 'catppuccin/vim', { 'as': 'catppuccin' }
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-surround'
        Plug 'tpope/vim-dispatch'
        Plug 'tpope/vim-sleuth'
        Plug 'tpope/vim-unimpaired'
        Plug 'tpope/vim-fugitive'
        Plug 'airblade/vim-gitgutter'
        Plug 'vim-airline/vim-airline'
        Plug 'christoomey/vim-tmux-navigator'
        Plug 'junegunn/fzf'
        Plug 'junegunn/fzf.vim'
        Plug 'tpope/vim-vinegar'
        Plug 'machakann/vim-highlightedyank'
        Plug 'vim-test/vim-test'
    endif

    if has('patch-9.0.0438') && executable('node')
        Plug 'neoclide/coc.nvim', { 'branch': 'release' }
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

let s:has_coc = s:has_vim_plug
            \ && s:PluginInstalled('coc.nvim')
            \ && has('patch-9.0.0438')
            \ && executable('node')
if s:has_coc
    function! s:EnsureCocExtensions(extensions) abort
        let l:data_home = get(g:, 'coc_data_home', '')
        if empty(l:data_home)
            let l:data_home = empty($XDG_CONFIG_HOME)
                        \ ? expand('~/.config/coc')
                        \ : expand($XDG_CONFIG_HOME . '/coc')
        endif
        let l:root = l:data_home . '/extensions'
        if !isdirectory(l:root)
            call mkdir(l:root, 'p')
        endif

        let l:package_json = l:root . '/package.json'
        if !filereadable(l:package_json)
            call writefile(['{"dependencies":{}}'], l:package_json)
        endif

        let l:missing = []
        for l:extension in a:extensions
            if !filereadable(l:root . '/node_modules/' . l:extension . '/package.json')
                call add(l:missing, l:extension)
            endif
        endfor

        if !empty(l:missing) && executable('npm')
            echom 'Installing Coc extensions: ' . join(l:missing, ', ')
            redraw
            let l:command = 'npm install --prefix ' . shellescape(l:root)
                        \ . ' --ignore-scripts --no-package-lock --omit=dev'
                        \ . ' --legacy-peer-deps --no-global'
            for l:extension in l:missing
                let l:command .= ' ' . shellescape(l:extension)
            endfor
            let l:output = system(l:command)
            if v:shell_error
                echohl WarningMsg
                echom 'Coc extension install failed: ' . substitute(l:output, '\n\+$', '', '')
                echohl None
            endif
        endif

        let l:installed = []
        for l:extension in a:extensions
            if filereadable(l:root . '/node_modules/' . l:extension . '/package.json')
                call add(l:installed, l:extension)
            endif
        endfor
        return l:installed
    endfunction

    let s:coc_extensions = [
                \ 'coc-clangd',
                \ 'coc-java',
                \ 'coc-pyright',
                \ 'coc-rust-analyzer',
                \ ]
    let g:coc_global_extensions = s:EnsureCocExtensions(s:coc_extensions)

    inoremap <silent><expr> <TAB>
        \ coc#pum#visible() ? coc#pum#next(1) :
        \ <SID>CheckBackspace() ? "\<Tab>" :
        \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
        \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"


    function! s:CheckBackspace() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    nnoremap <silent> K :call <SID>ShowDocumentation()<CR>

    function! s:ShowDocumentation() abort
        if index(['vim', 'help'], &filetype) >= 0
            execute 'help ' . expand('<cword>')
        elseif coc#rpc#ready()
            call CocActionAsync('doHover')
        else
            execute '!' . &keywordprg . ' ' . shellescape(expand('<cword>'))
        endif
    endfunction

    " Match Neovim 0.12's built-in LSP mappings.
    nmap <silent> gd  <Plug>(coc-definition)
    nmap <silent> gri <Plug>(coc-implementation)
    nmap <silent> grn <Plug>(coc-rename)
    nmap <silent> grr <Plug>(coc-references)
    nmap <silent> grt <Plug>(coc-type-definition)
    nmap <silent> grx <Plug>(coc-codelens-action)
    nmap <silent> gra <Plug>(coc-codeaction-cursor)
    xmap <silent> gra <Plug>(coc-codeaction-selected)
    nnoremap <silent> gO :call CocActionAsync('showOutline')<CR>

    nmap <silent> [d <Plug>(coc-diagnostic-prev)
    nmap <silent> ]d <Plug>(coc-diagnostic-next)

    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)
endif

if has('autocmd')
    augroup coc_config
        autocmd!
        if s:has_coc
            autocmd CursorHold * silent call CocActionAsync('highlight')
        endif
    augroup END
endif

" =============================================================================
" Cleanup
" =============================================================================
unlet! s:has_vim_plug
unlet! s:has_builtin_editorconfig
unlet! s:has_coc
unlet! s:coc_extensions
unlet! s:state_dir
unlet! s:swap_dir
unlet! s:undo_dir
unlet! s:backup_dir
