if exists('current_compiler')
  finish
endif
let current_compiler = 'cmake'

CompilerSet makeprg=cmake\ $*

" Multi-line: CMake Error at file:line (cmd):\n  message\n
" Single-line: CMake Error: message
CompilerSet errorformat^=
      \%ECMake\ Error\ at\ %f:%l\ (%m):,
      \%ECMake\ Error\ at\ %f:%l:,
      \%WCMake\ Warning\ at\ %f:%l\ (%m):,
      \%WCMake\ Warning\ at\ %f:%l:,
      \%ECMake\ Error:\ %m,
      \%WCMake\ Warning:\ %m,
      \%+C\ \ %m,
      \%-C%.%#,
      \%-Z,
