set nocompatible

" --- capabilities ------------------------------------------------------------
function! VimrcPatch(v) abort
    return v:version >= 704 && has('patch-' . a:v)
endfunction

let g:vimrc_async = has('job') && has('channel') && has('timers')
let g:vimrc_pack = has('packages')
let g:vimrc_popup = has('popupwin')
let g:vimrc_fuzzy = exists('*matchfuzzy')

" --- base options ------------------------------------------------------------
if has('multi_byte')
    set encoding=utf-8
    set fileencodings=ucs-bom,utf-8,latin1
endif

filetype plugin indent on
if has('syntax')
    syntax enable
    set cursorline
endif

" --- ui ----------------------------------------------------------------------
set number relativenumber
set showcmd ruler
set laststatus=2
set scrolloff=8 sidescrolloff=8
set splitbelow splitright
set hidden autoread
set lazyredraw
set noerrorbells novisualbell t_vb=
set backspace=indent,eol,start
set ttimeout ttimeoutlen=50
set updatetime=300
set display=lastline
set list listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
set shortmess+=I
set confirm
set mouse=nvi

if exists('+breakindent')
    set breakindent
endif
if exists('+signcolumn')
    set signcolumn=yes
endif
if has('cmdline_info')
    set showcmd
endif

" --- colors  -----------------------------------------------------------------
if has('termguicolors') && ($COLORTERM =~# 'truecolor\|24bit' || &term =~# 'kitty\|wezterm\|alacritty\|foot\|xterm-ghostty')
    if &term !=# 'win32'
        let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
    endif
    set termguicolors
elseif &term =~# '256color'
    set t_Co=256
endif
set background=dark
silent! colorscheme habamax
if !exists('g:colors_name')
    silent! colorscheme desert
endif

" --- finding files -----------------------------------------------------------
set path=.,,**
set suffixesadd=.h,.hpp,.c,.cc,.cpp,.java,.rs,.py,.ts,.js
set wildmenu
set wildmode=longest:full,full
set wildignore+=*.o,*.a,*.so,*.pyc,*.class,*/.git/*,*/node_modules/*,*/target/*,*/build/*
if exists('+wildignorecase')
    set wildignorecase
endif
if VimrcPatch('8.2.4325') && exists('+wildoptions')
    set wildoptions=pum,fuzzy
endif

" --- searching ---------------------------------------------------------------
set ignorecase smartcase
if has('extra_search')
    set hlsearch incsearch
endif
if exists('+inccommand')
    set inccommand=nosplit
endif

if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ --glob\ !.git
    set grepformat=%f:%l:%c:%m
else
    set grepprg=grep\ -RIn\ --exclude-dir=.git\ $*\ /dev/null
    set grepformat=%f:%l:%m
endif

command! -nargs=+ -complete=file Grep silent! grep! <args> | redraw!

" --- indent ------------------------------------------------------------------
set autoindent smartindent
set expandtab
set tabstop=4 softtabstop=4 shiftwidth=4
set shiftround
if v:version > 703
    set formatoptions+=j
endif

" --- completion --------------------------------------------------------------
set complete=.,w,b,u,t
set completeopt=menu,menuone
if VimrcPatch('8.1.1882')
    set completeopt+=popup
elseif v:version >= 800
    set completeopt+=preview
endif
set pumheight=10
set infercase

" --- files -------------------------------------------------------------------
set nobackup nowritebackup
set history=1000
set undolevels=1000
set sessionoptions-=options
set viewoptions-=options

function! s:ensuredir(path) abort
    if !isdirectory(expand(a:path)) && exists("*mkdir")
        silent! call mkdir(expand(a:path), 'p', 0700)
    endif
    return isdirectory(expand(a:path))
endfunction

if s:ensuredir('~/.vim/swap')
    set directory=~/.vim/swap//,.
endif
if has('persistent_undo') && s:ensuredir('~/.vim/undo')
    set undodir=~/.vim/undo
    set undofile
endif

" --- netrw -------------------------------------------------------------------
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_altv = 1
let g:netrw_winsize = 25
let g:netrw_list_hide = '^\.\.\=/\=$'

" --- autocmds ----------------------------------------------------------------
augroup vimrc_core
    autocmd!
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line('$')
        \ | execute 'normal! g`"' | endif
    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost l* nested lwindow
    autocmd InsertEnter * setlocal nolist
    autocmd InsertLeave * setlocal list
augroup END

" --- keymaps -----------------------------------------------------------------
let mapleader = ' '
let maplocalleader = ' '
nnoremap <Space> <Nop>

nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'
xnoremap <expr> j v:count == 0 ? 'gj' : 'j'
xnoremap <expr> k v:count == 0 ? 'gk' : 'k'
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv

xnoremap < <gv
xnoremap > >gv
xnoremap <silent> J :move '>+1<CR>gv=gv
xnoremap <silent> K :move '<-2<CR>gv=gv
nnoremap Y y$
nnoremap <silent> <leader>h :nohlsearch<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <leader>w :write<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>e :Explore<CR>
nnoremap <leader><Space> :find<Space>
nnoremap <leader>, :buffer<Space>
nnoremap <leader>bd :bdelete<CR>

command! -nargs=+ -complete=file Grep silent! grep! <args> | redraw!
nnoremap <leader>/ :Grep<Space>
nnoremap <leader>* :Grep <C-r><C-w><CR>
xnoremap <leader>* y:Grep <C-r>"<CR>

nnoremap <silent> ]q :cnext<CR>zz
nnoremap <silent> [q :cprevious<CR>zz
nnoremap <silent> ]Q :clast<CR>zz
nnoremap <silent> [Q :cfirst<CR>zz
nnoremap <silent> ]l :lnext<CR>zz
nnoremap <silent> [l :lprevious<CR>zz
nnoremap <silent> ]L :llast<CR>zz
nnoremap <silent> [L :lfirst<CR>zz
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]t :tabnext<CR>
nnoremap <silent> [t :tabprevious<CR>

function! s:toggle_qf(which) abort
    let l:loclist = a:which !=# 'c'
    for l:w in range(1, winnr('$'))
        if getwinvar(l:w, '&buftype') ==# 'quickfix'
                    \ && (!empty(getloclist(l:w))) == l:loclist
            execute l:loclist ? 'lclose' : 'cclose'
            return
        endif
    endfor
    if l:loclist && empty(getloclist(0))
        echohl WarningMsg | echomsg 'no location list' | echohl None
        return
    endif
    execute l:loclist ? 'lopen' : 'botright copen'
endfunction
nnoremap <silent> <leader>xq :call <SID>toggle_qf('c')<CR>
nnoremap <silent> <leader>xl :call <SID>toggle_qf('l')<CR>

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

if exists(':terminal') == 2
    tnoremap <Esc><Esc> <C-\><C-n>
    nnoremap <leader>t :terminal<CR>
endif

" --- statusline --------------------------------------------------------------
function! VimrcMode() abort
    let l:m = mode()
    let l:map = {'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL',
        \ 'V': 'V-LINE', "\<C-v>": 'V-BLOCK', 'c': 'COMMAND', 's': 'SELECT',
        \ 'S': 'S-LINE', "\<C-s>": 'S-BLOCK', 't': 'TERMINAL', '!': 'SHELL'}
    return get(l:map, l:m, toupper(l:m))
endfunction

function! VimrcGitBranch() abort
    if !exists('b:vimrc_branch')
        let b:vimrc_branch = ''
        if exists('*FugitiveHead')
            let b:vimrc_branch = FugitiveHead()
        elseif executable('git')
            let l:dir = expand('%:p:h')
            if l:dir !=# ''
                let l:out = system('git -C ' . shellescape(l:dir) . ' rev-parse --abbrev-ref HEAD 2>/dev/null')
                if v:shell_error == 0
                    let b:vimrc_branch = substitute(l:out, '\n', '', 'g')
                endif
            endif
        endif
    endif
    return b:vimrc_branch ==# '' ? '' : ' ' . b:vimrc_branch . ' '
endfunction

augroup vimrc_statusline
    autocmd!
    autocmd BufEnter,BufWritePost * unlet! b:vimrc_branch
augroup END

set laststatus=2
set noshowmode
set statusline=
set statusline+=%#PmenuSel#\ %{VimrcMode()}\ %*
set statusline+=%{VimrcGitBranch()}
set statusline+=\ %f
set statusline+=%m%r%h%w
set statusline+=%=
set statusline+=%{&filetype}\ 
set statusline+=%{&fileformat}\ 
set statusline+=%{(&fileencoding!=''?&fileencoding:&encoding)}\ 
set statusline+=%#PmenuSel#\ %2l:%-2v\ %3p%%\ %*

" --- clipboard ---------------------------------------------------------------
if has('clipboard') && empty($SSH_TTY) && empty($SSH_CONNECTION)
    set clipboard=unnamed
    if has('unnamedplus')
        set clipboard=unnamedplus
    endif
endif

let s:b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function! s:b64encode(str) abort
    let l:bytes = []
    for l:i in range(len(a:str))
        call add(l:bytes, char2nr(a:str[l:i]))
    endfor
    let l:out = ''
    let l:i = 0
    let l:n = len(l:bytes)
    while l:i < l:n
        let l:b0 = l:bytes[l:i]
        let l:b1 = (l:i + 1 < l:n) ? l:bytes[l:i + 1] : 0
        let l:b2 = (l:i + 2 < l:n) ? l:bytes[l:i + 2] : 0
        let l:out .= s:b64[l:b0 / 4]
        let l:out .= s:b64[(l:b0 % 4) * 16 + l:b1 / 16]
        let l:out .= (l:i + 1 < l:n) ? s:b64[(l:b1 % 16) * 4 + l:b2 / 64] : '='
        let l:out .= (l:i + 2 < l:n) ? s:b64[l:b2 % 64] : '='
        let l:i += 3
    endwhile
    return l:out
endfunction

function! VimrcOsc52(text) abort
    let l:seq = "\<Esc>]52;c;" . s:b64encode(a:text) . "\<Esc>\\"
    if !empty($TMUX)
        let l:seq = "\<Esc>Ptmux;" . substitute(l:seq, "\<Esc>", "\<Esc>\<Esc>", 'g') . "\<Esc>\\"
    elseif &term =~# '^screen'
        let l:seq = "\<Esc>P" . substitute(l:seq, "\<Esc>", "\<Esc>\<Esc>", 'g') . "\<Esc>\\"
    endif
    if filewritable('/dev/tty')
        call writefile([l:seq], '/dev/tty', 'b')
    else
        silent! execute "!printf '%s' " . shellescape(l:seq)
        redraw!
    endif
endfunction

function! s:yank_osc52(type) abort
    let l:save = @@
    if a:type ==# 'line'
        silent normal! '[V']y
    elseif a:type ==# 'visual'
        silent normal! gvy
    elseif a:type ==# 'block'
        silent execute "normal! `[\<C-v>`]y"
    else
        silent normal! `[v`]y
    endif
    call VimrcOsc52(@@)
    let @@ = l:save
endfunction

nnoremap <silent> <leader>y :set operatorfunc=<SID>yank_osc52<CR>g@
nnoremap <silent> <leader>yy :call <SID>yank_osc52('line')<CR>
xnoremap <silent> <leader>y :<C-u>call <SID>yank_osc52('visual')<CR>
command! -range=% Copy silent execute <line1> . ',' . <line2> . 'yank' |
            \ call VimrcOsc52(@@)

" --- tags --------------------------------------------------------------------
"set tags=./tags;,tags;
"if exists('+tagcase')
"    set tagcase=match
"endif
"nnoremap <C-]> g<C-]>
"nnoremap <leader>] :tselect <C-r><C-w><CR>
"
"function! VimrcRoot() abort
"    let l:markers = ['.git', '.hg', '.svn', 'compile_commands.json',
"                \ 'Cargo.toml', 'go.mod', 'pom.xml', 'CMakeLists.txt', 'Makefile']
"    let l:dir = expand('%:p:h')
"    if l:dir ==# ''
"        let l:dir = getcwd()
"    endif
"    while l:dir !=# '/' && l:dir !=# ''
"        for l:m in l:markers
"            if !empty(glob(l:dir . '/' . l:m, 1))
"                return l:dir
"            endif
"        endfor
"        let l:parent = fnamemodify(l:dir, ':h')
"        if l:parent ==# l:dir
"            break
"        endif
"        let l:dir = l:parent
"    endwhile
"    return getcwd()
"endfunction
"command! Root execute 'lcd' fnameescape(VimrcRoot()) | pwd
"
"function! VimrcTags() abort
"    let l:bin = ''
"    for l:c in ['ctags-universal', 'uctags', 'exctags', 'ctags']
"        if executable(l:c) && system(l:c . ' --version 2>&1') =~? 'universal ctags\|exuberant ctags'
"            let l:bin = l:c
"            break
"        endif
"    endfor
"    if l:bin ==# ''
"        echohl ErrorMsg | echomsg 'no universal/exuberant ctags' | echohl None
"        return
"    endif
"    let l:root = VimrcRoot()
"    let l:cmd = l:bin . ' -R --exclude=.git --exclude=node_modules --exclude=target -f '
"                \ . shellescape(l:root . '/tags') . ' ' . shellescape(l:root)
"    if g:vimrc_async
"        call job_start(['sh', '-c', l:cmd])
"    else
"        call system(l:cmd)
"    endif
"    echomsg 'ctags: ' . l:root
"endfunction
"command! Tags call VimrcTags()
"
"" --- plugins - ---------------------------------------------------------------
"let g:vimrc_plugins = get(g:, 'vimrc_plugins', [
"    \ 'tpope/vim-sleuth',
"    \ 'tpope/vim-commentary',
"    \ 'tpope/vim-surround',
"    \ 'tpope/vim-repeat',
"    \ 'tpope/vim-eunuch',
"    \ 'tpope/vim-vinegar',
"    \ 'tpope/vim-fugitive',
"    \ 'tpope/vim-dispatch',
"    \ 'vim-test/vim-test',
"    \ 'mbbill/undotree',
"    \ 'junegunn/fzf',
"    \ 'junegunn/fzf.vim',
"    \ ])
"
"function! s:pack(pull) abort
"    for l:repo in g:vimrc_plugins
"        let l:d = expand('~/.vim/pack/plugins/start/') . matchstr(l:repo, '[^/]*$')
"        redraw | echo (isdirectory(l:d) ? 'pull  ' : 'clone ') . l:repo
"        if !isdirectory(l:d)
"            call system('git clone -q --depth 1 https://github.com/' . l:repo . ' ' . shellescape(l:d))
"        elseif a:pull
"            call system('git -C ' . shellescape(l:d) . ' pull -q --ff-only')
"        endif
"    endfor
"    silent! packloadall
"    silent! helptags ALL
"    echo 'pack: done'
"endfunction
"command! -bang Pack call s:pack(<bang>0)
"
"let g:vimrc_have_plugins = g:vimrc_pack
"    \ && isdirectory(expand('~/.vim/pack/plugins/start'))
"
"if g:vimrc_have_plugins
"    function! s:have(name) abort
"        return isdirectory(expand('~/.vim/pack/plugins/start/' . a:name))
"    endfunction
"
"    if s:have('vim-vinegar')
"        nmap <leader>e -
"    endif
"
"    if s:have('vim-fugitive')
"        nnoremap <leader>gs :Git<CR>
"        nnoremap <leader>gb :Git blame<CR>
"        nnoremap <leader>gd :Gvdiffsplit<CR>
"        nnoremap <leader>gl :Git log --oneline<CR>
"    endif
"
"    if executable('fzf') && s:have('fzf.vim')
"        let g:fzf_layout = {'down': '40%'}
"        let $FZF_DEFAULT_COMMAND = executable('rg')
"                \ ? 'rg --files --hidden --glob !.git'
"                \ : 'find . -type f -not -path "*/.git/*"'
"        nnoremap <leader><space> :Files<CR>
"        nnoremap <leader>, :Buffers<CR>
"        nnoremap <leader>/ :Rg<CR>
"    endif
"endif
"
"if VimrcPatch('9.0.1799')
"    let g:editorconfig = 1
"endif
