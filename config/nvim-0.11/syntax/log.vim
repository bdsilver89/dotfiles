if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case match

syn match logFatalRecord /.*\<\(FATAL\|FTL\)\>.*/
syn match logCriticalRecord /.*\<\(CRITICAL\|CTL\)\>.*/
syn match logErrorRecord /.*\<\(ERROR\|ERR\)\>.*/
syn match logWarningRecord /.*\<\(WARNING\|WARN\|WRN\)\>.*/
syn match logInfoRecord /.*\<\(INFO\|INF\)\>.*/
syn match logDebugRecord /.*\<\(DEBUG\|DBG\)\>.*/
syn match logTraceRecord /.*\<\(TRACE\|TRC\)\>.*/

hi link logFatalRecord ErrorMsg
hi link logCriticalRecord ErrorMsg
hi link logErrorRecord ErrorMsg
hi link logWarningRecord WarningMsg
hi link logInfoRecord MoreMsg
hi link logDebugRecord Debug
hi link logTraceRecord Comment

let b:current_syntax="log-simple"
