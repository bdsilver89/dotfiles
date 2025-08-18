if exists("current_compiler")
    finish
endif
runtime compiler/gcc.vim
let current_compiler = "ninja"

let s:save_cpo = &cpo
set cpo&vim

CompilerSet makeprg=ninja\ $*

"augroup NinjaQuickFixHooks
"    autocmd!
"    autocmd QuickFixCmdPre make call ninja#quickfix#CmdPre()
"    autocmd QuickFixCmdPost make call ninja#quickfix#CmdPost()
"augroup END

" Ninja error patterns
CompilerSet errorformat+=
    \FAILED:\ %f,
    \ninja:\ build\ stopped:\ %m,
    \ninja:\ error:\ %m,
    \%Eninja:\ error:\ %f:%l:\ %m,
    \%Eninja:\ error:\ %f:\ %m

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sw=4 sts=4 ts=8
