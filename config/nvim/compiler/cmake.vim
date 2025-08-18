if exists("current_compiler")
    finish
endif
runtime compiler/gcc.vim
let current_compiler = "cmake"

let s:save_cpo = &cpo
set cpo&vim

CompilerSet makeprg=cmake\ $*

" CMake error patterns
CompilerSet errorformat+=
    \%ECMake\ Error\ at\ %f:%l\ (%m):,
    \%ZCall\ Stack\ %.%#,
    \%ECMake\ Error\ at\ %f:%l:,
    \%Z\ \ %m,
    \%ECMake\ Error\ in\ %f:,
    \%Z\ \ %m,
    \%ECMake\ Error:\ %m,
    \%WCMake\ Warning\ at\ %f:%l\ (%m):,
    \%WCMake\ Warning\ at\ %f:%l:,
    \%WCMake\ Warning\ in\ %f:,
    \%WCMake\ Warning:\ %m,
    \%Emake[%*\\d]:\ ***\ [%f:%l]\ Error\ %n,
    \%Emake:\ ***\ [%f:%l]\ Error\ %n

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sw=4 sts=4 ts=8
