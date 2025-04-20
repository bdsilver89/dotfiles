NOCOL="\[\e[0m\]"

__username() {
  echo "\[\e[1;34m\]\u$NOCOL"
}

__host() {
  echo "\[\e[0;34m\]\h$NOCOL"
}

__path() {
  echo "\[\e[0;32m\]\w$NOCOL"
}

__separator() {
  local color=${2:-30}
  echo "\[\e[1;${color}m\]$1$NOCOL"
}

__prompt() {
  echo "\$ $NOCOL"
}

# PS1="$(__username)$(__separator @ "34")$(__host)$(__separator : "34")$(__path)$(__git_ps1)$(__prompt)"
PS1='\[\e[0;34m\]\u@\h\[\e[0m\]:\[\e[0;32m\]\w\[\e[0;33m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ '
