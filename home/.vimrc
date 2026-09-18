scriptencoding utf-8

" ============================================================================
" Requirements
" ============================================================================
if !has('patch-8.2.0750')
    echoerr 'This configuration requires Vim 8.2.0750 or newer'
    finish
endif

for s:tool in ['git', 'rg', 'fzf', 'node']
    if !executable(s:tool)
        call add(s:missing_tools, s:tool)
        echohl WarningMsg
        echom 'vimrc: optional tools missing: ' . s:tool
        echohl None
        finish
    endif
endfor

set nocompatible
let mapleader = ' '
let maplocalleader = ','

" Coc needs these features
let s:coc_supported =
            \ has('job') &&
            \ has('popupwin') &&
            \ has('textprop')

" Older Vim runtimes need compiler parsers for Maven and pytest.
let s:maven_compiler_bundled =
      \ !empty(globpath(&runtimepath, 'compiler/maven.vim'))
let s:pytest_compiler_bundled =
      \ !empty(globpath(&runtimepath, 'compiler/pytest.vim'))

" Select vimspector version
let s:vimspector_current = 0
let s:vimspector_legacy = 0

if has('huge') && has('python3')
    if has('patch-8.2.4797') &&
                \ py3eval('__import__("sys").version_info >= (3, 10)')
        let s:vimspector_current = 1
    elseif py3eval('__import__("sys").version_info >= (3, 6)')
        let s:vimspector_legacy = 1
    endif
endif

" ============================================================================
" Plugin bootstrap
" ============================================================================
let s:plug_path = expand('~/.vim/autoload/plug.vim')
let s:plugins_enabled = filereadable(s:plug_path)

if !s:plugins_enabled && executable('curl')
    let s:plug_url =
                \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    call system(
                \ 'curl --fail --location --create-dirs --output ' .
                \ shellescape(s:plug_path) . ' ' .
                \ shellescape(s:plug_url))

    let s:plugins_enabled = v:shell_error == 0 && filereadable(s:plug_path)
endif

if s:plugins_enabled
    call plug#begin(expand('~/.vim/plugged'))

    " UI
    " Plug 'catppuccin/vim', {'as': 'catppuccin', 'branch': 'main' }
    Plug 'sainnhe/everforest'
    Plug 'itchyny/lightline.vim'
    Plug 'Yggdroot/indentline'
    Plug 'mbbill/undotree'

    " Search and navigation
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'tpope/vim-vinegar'
    Plug 'christoomey/vim-tmux-navigator'

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'

    " Editing
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-sleuth'

    if !has('patch-9.0.1799')
        Plug 'editorconfig/editorconfig-vim'
    endif

    " LSP and completion
    if s:coc_supported
        if has('patch-9.0.0438')
            Plug 'neoclide/coc.nvim', {'branch': 'release'}
        else
            Plug 'neoclide/coc.nvim', {
                        \ 'commit': 'f0ce9ae23d6ce9d0cbabe73bdb738e45accc6f08'
                        \ }
        endif
    endif

    " Testing and builds
    Plug 'tpope/vim-dispatch'
    Plug 'vim-test/vim-test'

    if !s:maven_compiler_bundled
        Plug 'mikelue/vim-maven-plugin'
    endif

    if !s:pytest_compiler_bundled
        Plug '5long/pytest-vim-compiler'
    endif

    " Debugging
    if s:vimspector_current
        Plug 'puremourning/vimspector'
    elseif s:vimspector_legacy
        Plug 'puremourning/vimspector', {'tag': '4722501279'}
    endif

    call plug#end()

    let s:missing_plugins =
                \ !empty(filter(values(g:plugs), '!isdirectory(v:val.dir)'))

    if s:missing_plugins
        function! s:InstallPlugins() abort
            PlugInstall --sync
            execute 'source ' . fnameescape($MYVIMRC)
        endfunction

        augroup vimrc_bootstrap
            autocmd!
            autocmd VimEnter * ++once call <SID>InstallPlugins()
        augroup END
    endif
endif

filetype plugin indent on
syntax on

let s:coc_enabled = s:plugins_enabled && s:coc_supported
let s:vimspector_enabled = s:plugins_enabled &&
          \ (s:vimspector_current || s:vimspector_legacy)

" ============================================================================
" Core options
" ============================================================================
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

set list
set listchars=tab:»·,trail:·,extends:›,precedes:‹,nbsp:+
set signcolumn=yes

set splitbelow
set splitright

set ignorecase
set smartcase
set incsearch
set hlsearch

set wildmenu
set wildignorecase

set showcmd
set noshowmode
set noruler
set laststatus=2

set updatetime=300
set timeout
set ttimeout
set ttimeoutlen=200

set pumheight=10
set mouse=a
set noexrc

set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

if has('unnamedplus')
    set clipboard=unnamedplus
elseif has('clipboard')
    set clipboard=unnamed
endif

" ============================================================================
" Persistent state
" ============================================================================
let s:state_root = expand('~/.vim/state')
let s:undo_dir = s:state_root . '/undo'
let s:swap_dir = s:state_root . '/swap'
let s:backup_dir = s:state_root . '/backup'

for s:directory in [s:undo_dir, s:swap_dir, s:backup_dir]
    if !isdirectory(s:directory)
        call mkdir(s:directory, 'p', 0700)
    endif
endfor

let &undodir = s:undo_dir . '//'
let &directory = s:swap_dir . '//'
let &backupdir = s:backup_dir . '//'

set undofile
set undolevels=1000
set backup
set nowritebackup

" ============================================================================
" UI
" ============================================================================
set background=dark

if exists('+termguicolors')
    set termguicolors

    if &term =~# '256color' || &term =~# 'tmux'
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
endif

" silent! colorscheme catppuccin_mocha
silent! colorscheme everforest

function! LightlineGitBranch() abort
    return exists('*FugitiveHead') ? FugitiveHead() : ''
endfunction

function! LightlineCocStatus() abort
    if get(g:, 'coc_service_initialized', 0)
        return coc#status()
    endif
    return ''
endfunction

let g:lightline = {
            \
            \ 'colorscheme': 'catppuccin_mocha',
            \ 'active': {
            \   'left': [
            \     ['mode', 'paste'],
            \     ['gitbranch', 'readonly', 'filename', 'modified']
            \   ],
            \   'right': [
            \     ['lineinfo'],
            \     ['percent'],
            \     ['cocstatus', 'filetype', 'fileencoding', 'fileformat']
            \   ]
            \ },
            \ 'component_function': {
            \   'gitbranch': 'LightlineGitBranch',
            \   'cocstatus': 'LightlineCocStatus'
            \ }
            \ }

" ============================================================================
" Plugin settings
" ============================================================================
" Keep JSON and Markdown punctuation visible.
let g:indentLine_setColors = 0
let g:indentLine_char = '┊'
let g:vim_json_conceal = 0
let g:markdown_syntax_conceal = 0

let g:undotree_WindowLayout = 3
let g:undotree_SetFocusWhenToggle = 0
let g:undotree_SplitWidth = 30

let g:netrw_banner = 0

let g:EditorConfig_exclude_patterns = [
            \ 'fugitive://.*',
            \ 'scp://.*'
            \ ]

let g:fzf_vim = {
            \ 'buffers_jump': 1,
            \ 'preview_window': ['hidden,right,50%,<70(up,40%)', 'ctrl-/']
            \ }

let $FZF_DEFAULT_COMMAND =
            \ "rg --files --hidden --glob '!.git/*'"
let $FZF_CTRL_T_COMMAND = $FZF_DEFAULT_COMMAND

let test#strategy = 'dispatch'
let test#python#runner = 'pytest'
let g:dispatch_compilers = {
            \ 'pytest': 'pytest',
            \ 'python -m pytest': 'pytest'
            \ }

let g:maven_auto_chdir = 0
let g:maven_auto_set_path = 0
let g:maven_keymaps = 0

if s:coc_enabled
    let g:coc_global_extensions = [
                \ 'coc-clangd',
                \ 'coc-java',
                \ 'coc-basedpyright',
                \ 'coc-rust-analyzer',
                \ 'coc-json',
                \ 'coc-snippets'
                \ ]

    let g:coc_snippet_next = '<C-j>'
    let g:coc_snippet_prev = '<C-k>'
endif

if s:vimspector_enabled
    let g:vimspector_install_gadgets = [
                \ 'CodeLLDB',
                \ 'debugpy',
                \ 'vscode-java-debug'
                \ ]
endif

" ============================================================================
" Project helpers
" ============================================================================
function! ProjectRoot() abort
    let l:start = expand('%:p:h')

    if empty(l:start) || !isdirectory(l:start)
        let l:start = getcwd()
    endif

    if executable('git')
        let l:root = systemlist(
                    \ 'git -C ' . shellescape(l:start) .
                    \ ' rev-parse --show-toplevel 2>/dev/null')

        if v:shell_error == 0 && !empty(l:root)
            return l:root[0]
        endif
    endif

    return getcwd()
endfunction

" vim-test runs without changing Vim's working directory.
" Use a string because Vim before 9.0.0355 rejects Funcrefs here.
let test#project_root = ProjectRoot()

function! s:ProjectFiles(fullscreen) abort
    let l:root = ProjectRoot()
    let l:is_git = executable('git') &&
                \ system(
                \     'git -C ' . shellescape(l:root) .
                \     ' rev-parse --is-inside-work-tree 2>/dev/null'
                \ ) =~# 'true'

    let l:options = fzf#vim#with_preview({'dir': l:root})

    if l:is_git
        call fzf#vim#gitfiles('', l:options, a:fullscreen)
    else
        call fzf#vim#files(l:root, l:options, a:fullscreen)
    endif
endfunction

command! -bang ProjectFiles call <SID>ProjectFiles(<bang>0)

function! s:FindBuildProject() abort
    let l:directory = expand('%:p:h')

    if empty(l:directory) || !isdirectory(l:directory)
        let l:directory = getcwd()
    endif

    let l:markers = [
                \ 'pom.xml',
                \ 'Cargo.toml',
                \ 'CMakeLists.txt',
                \ 'Makefile',
                \ ]

    while 1
        for l:marker in l:markers
            if filereadable(l:directory . '/' . l:marker)
                return {'root': l:directory, 'marker': l:marker}
            endif
        endfor

        let l:parent = fnamemodify(l:directory, ':h')
        if l:parent ==# l:directory
            return {}
        endif
        let l:directory = l:parent
    endwhile
endfunction

function! s:SetCompiler(name) abort
    try
        execute 'compiler ' . a:name
        return 1
    catch /^Vim\%((\a\+)\)\=:E666:/
        echohl WarningMsg
        echom 'vimrc: compiler unavailable: ' . a:name
        echohl None
        return 0
    endtry
endfunction

function! s:ConfigureBuild() abort
    if &l:buftype !=# ''
        return 0
    endif

    let l:project = s:FindBuildProject()
    if empty(l:project)
        if exists('b:build_root')
            unlet! b:build_marker b:build_root
            unlet! b:current_compiler
            setlocal makeprg< errorformat<
        endif
        return 0
    endif

    if get(b:, 'build_root', '') ==# l:project.root &&
                \ get(b:, 'build_marker', '') ==# l:project.marker
        return 1
    endif

    if l:project.marker ==# 'pom.xml'
        if !s:SetCompiler('maven')
            return 0
        endif
        let program = executable(l:project.root . '/mvnw')
                    \ ? l:project.root . '/mvnw' : 'mvn'
        let &l:makeprg = shellescape(l:program) . ' -B -f ' .
                    \ shellescape(l:project.root . '/pom.xml') . ' $*'
    elseif l:project.marker ==# 'Cargo.toml'
        if !s:SetCompiler('cargo')
            return 0
        endif
        let &l:makeprg = 'cargo --manifest-path ' .
                    \ shellescape(l:project.root . '/Cargo.toml') . ' $*'
    elseif l:project.marker ==# 'CMakeLists.txt'
        if !s:SetCompiler('gcc')
            return 0
        endif
        let l:build_directory = filereadable(l:project.root . '/CMakeCache.txt')
                    \ ? l:project.root : l:project.root . '/build'
        let &l:makeprg = 'cmake --build ' .
                    \ shellescape(l:build_directory) . ' $*'
    else
        if !s:SetCompiler('gcc')
            return 0
        endif
        let &l:makeprg = 'make -C ' . shellescape(l:project.root) . ' $*'
    endif

    let b:build_root = l:project.root
    let b:build_marker = l:project.marker

    return 1
endfunction

" ============================================================================
" General mappings
" ============================================================================
nnoremap <silent><expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <silent><expr> k v:count == 0 ? 'gk' : 'k'

nnoremap <silent> <C-d> <C-d>zz
nnoremap <silent> <C-u> <C-u>zz
nnoremap <silent> n nzzzv
nnoremap <silent> N Nzzzv
nnoremap <silent> <Esc> :nohlsearch<CR>

nnoremap <silent> <leader>- :split<CR>
nnoremap <silent> <leader><Bar> :vsplit<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

xnoremap < <gv
xnoremap > >gv

if has('terminal')
    tnoremap <Esc><Esc> <C-\><C-n>
endif

" ============================================================================
" LSP and completion
" ============================================================================
if s:coc_enabled
    function! s:CheckBackspace() abort
        let l:column = col('.') - 1
        return !l:column || getline('.')[l:column - 1] =~# '\s'
    endfunction

    function! s:ShowDocumentation() abort
        if CocAction('hasProvider', 'hover')
            call CocActionAsync('definitionHover')
        else
            normal! K
        endif
    endfunction

    inoremap <silent><expr> <Tab>
                \ coc#pum#visible() ? coc#pum#next(1) :
                \ <SID>CheckBackspace() ? "\<Tab>" :
                \ coc#refresh()

    inoremap <silent><expr> <S-Tab>
                \ coc#pum#visible() ? coc#pum#prev(1) :
                \ "\<C-h>"

    inoremap <silent><expr> <CR>
                \ coc#pum#visible() ? coc#pum#select_confirm() :
                \ "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"

    " Vim receives Ctrl-Space as Ctrl-@ in terminal input.
    inoremap <silent><expr> <C-@> coc#refresh()
    inoremap <silent> <C-s>
                \ <C-r>=CocActionAsync('showSignatureHelp')<CR>

    nmap <silent> gd  <Plug>(coc-definition)
    nmap <silent> gD  <Plug>(coc-declaration)
    nmap <silent> gri <Plug>(coc-implementation)
    nmap <silent> grn <Plug>(coc-rename)
    nmap <silent> grr <Plug>(coc-references)
    nmap <silent> grt <Plug>(coc-type-definition)

    nmap <silent> gra <Plug>(coc-codeaction-cursor)
    xmap <silent> gra <Plug>(coc-codeaction-selected)

    nnoremap <silent> gO :CocList outline<CR>
    nnoremap <silent> K :call <SID>ShowDocumentation()<CR>

    nmap <silent> [d <Plug>(coc-diagnostic-prev)
    nmap <silent> ]d <Plug>(coc-diagnostic-next)

    nnoremap <silent> <leader>lf
                \ :call CocActionAsync('format')<CR>
    nnoremap <silent> <leader>lS
                \ :CocList -I symbols<CR>
    nnoremap <silent> <leader>ld
                \ :CocList diagnostics<CR>

    command! Format call CocActionAsync('format')
endif

" ============================================================================
" Finder mappings
" ============================================================================
if s:plugins_enabled
    nnoremap <silent> <leader>sf :Files<CR>
    nnoremap <silent> <leader>sg :RG<CR>
    nnoremap <silent> <leader>sb :Buffers<CR>
    nnoremap <silent> <leader>sh :History<CR>
    nnoremap <silent> <leader>sl :BLines<CR>
    nnoremap <silent> <leader>sL :Lines<CR>
    nnoremap <silent> <leader>sc :Commands<CR>
endif

" ============================================================================
" Git mappings
" ============================================================================
if s:plugins_enabled
    nnoremap <silent> <leader>gs :Git<CR>
    nnoremap <silent> <leader>ga :Git add %<CR>
    nnoremap <silent> <leader>gu :Git reset -q %<CR>
    nnoremap <silent> <leader>gc :Git commit<CR>
    nnoremap <silent> <leader>gp :Git push<CR>
    nnoremap <silent> <leader>gd :Gdiffsplit<CR>
    nnoremap <silent> <leader>gb :Git blame<CR>

    nmap <silent> <leader>hp <Plug>(GitGutterPreviewHunk)
    nmap <silent> <leader>hs <Plug>(GitGutterStageHunk)
    nmap <silent> <leader>hu <Plug>(GitGutterUndoHunk)
endif

" ============================================================================
" Test and build mappings
" ============================================================================
if s:plugins_enabled
    nnoremap <silent> <leader>tn :TestNearest<CR>
    nnoremap <silent> <leader>tf :TestFile<CR>
    nnoremap <silent> <leader>ts :TestSuite<CR>
    nnoremap <silent> <leader>tl :TestLast<CR>
    nnoremap <silent> <leader>tv :TestVisit<CR>
endif

" ============================================================================
" Debug mappings
" ============================================================================
if s:vimspector_enabled
    nmap <silent> <leader>dc <Plug>VimspectorContinue
    nmap <silent> <leader>dq <Plug>VimspectorStop
    nmap <silent> <leader>dr <Plug>VimspectorRestart
    nmap <silent> <leader>dp <Plug>VimspectorPause
    nmap <silent> <leader>db <Plug>VimspectorToggleBreakpoint
    nmap <silent> <leader>dB <Plug>VimspectorToggleConditionalBreakpoint
    nmap <silent> <leader>do <Plug>VimspectorStepOver
    nmap <silent> <leader>di <Plug>VimspectorStepInto
    nmap <silent> <leader>du <Plug>VimspectorStepOut
    nmap <silent> <leader>dt <Plug>VimspectorRunToCursor
    nmap <silent> <leader>de <Plug>VimspectorBalloonEval
    xmap <silent> <leader>de <Plug>VimspectorBalloonEval
    nmap <silent> <leader>df <Plug>VimspectorUpFrame
    nmap <silent> <leader>dF <Plug>VimspectorDownFrame
endif

" ============================================================================
" UI and list mappings
" ============================================================================
nnoremap <silent> <leader>ui :IndentLinesToggle<CR>
nnoremap <silent> <leader>uu :UndotreeToggle<CR>

function! s:ToggleQuickfix() abort
    for l:window in getwininfo()
        if get(l:window, 'quickfix', 0) &&
                    \ !get(l:window, 'loclist', 0)
            cclose
            return
        endif
    endfor

    copen
endfunction

function! s:ToggleLocationList() abort
    let l:list = getloclist(0, {'winid': 0})

    if get(l:list, 'winid', 0)
        lclose
    else
        silent! lopen
    endif
endfunction

nnoremap <silent> <leader>xq :call <SID>ToggleQuickfix()<CR>
nnoremap <silent> <leader>xl :call <SID>ToggleLocationList()<CR>

" ============================================================================
" Commands and autocmds
" ============================================================================
augroup init
    autocmd!

    autocmd VimResized * wincmd =

    autocmd BufEnter * let test#project_root = ProjectRoot()
    autocmd BufEnter * call <SID>ConfigureBuild()

    if s:coc_enabled
        autocmd CursorHold *
                    \ silent call CocActionAsync('highlight')
        autocmd User CocStatusChange,CocDiagnosticChange
                    \ call lightline#update()
    endif
augroup END
