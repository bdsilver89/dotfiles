alias ..="cd .."
alias ...="cd ../.."

alias c="clear"

alias df="df -h"
alias pg="ps aux | grep -v grep | grep -i -e VSZ -e"

# Debian/Ubuntu ship these under different binary names
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat="batcat"
command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd="fdfind"

if command -v eza >/dev/null 2>&1; then
  alias l="eza --color=always --icons=always --git"
  alias ll="eza --color=always --icons=always --git -lagSX"
  alias lt="eza --color=always --tree --level=2 --icons=always --long --git"
else
  alias l="ls --color=auto"
  alias ll="ls -lah --color=auto"
  command -v tree >/dev/null 2>&1 && alias lt="tree"
fi

command -v lazygit >/dev/null 2>&1 && alias gg="lazygit"
alias g="git"
