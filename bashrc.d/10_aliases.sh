# shortcuts
alias c="clear"

# navigation
alias ..="cd .."
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."

# adding flags
alias df="df -h"

# ps
alias pg="ps aux | grep -v grep | grep -i -e VSZ -e"

# eza/exa/ls
if [ -x "$(command -v eza)" ]; then
  alias ls="eza --color=always --icons=always --git"
  alias lt="exa --color=always --tree --level=2 --icons=always --long --git"
elif [ -x "$(command -v exa)" ]; then
  alias ls="exa --color=always"
  alias lt="exa --color=always --tree --level=2 --long"
else
  alias ls="ls --color=auto"
  if [ -x "$(command -v tree)" ]; then
    alias lt="tree"
  fi
fi
alias l="ls -lah"

# bat is sometimes installed as batcat
if [ -x "$(command -v batcat)" ]; then
  alias bat="batcat"
fi

# fd is sometimes installed as fdfind
if [ -x "$(command -v fdfind)" ]; then
  alias fd="fdfind"
fi

# git
alias g="git"

alias ga='git add'
alias gbl='git blame -w'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gclean='git clean --interactive -d'
alias gcl='git clone --recurse-submodules'
alias gc='git commit --verbose'
alias gcmsg='git commit --message'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'
alias gf='git fetch'
alias gfo='git fetch origin'
alias glgg='git log --graph'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glg='git log --stat'
alias glgp='git log --stat --patch'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias gfg='git ls-files | grep'
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms="git merge --squash"
alias gmff="git merge --ff-only"
alias gmom='git merge origin/$(git_main_branch)'
alias gmum='git merge upstream/$(git_main_branch)'
alias gmtl='git mergetool --no-prompt'
alias gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias gl='git pull'
alias gp='git push'
alias gpd='git push --dry-run'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbi='git rebase --interactive'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias grh='git reset'
alias grs='git restore'
alias grs='git restore'
alias gst='git status'
alias gsta='git stash push'
alias gstp='git stash pop'
