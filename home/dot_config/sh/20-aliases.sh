# Shared aliases. POSIX only — sourced by both zsh and bash.
# Runs after 00-path.sh so the command -v guards below see ~/.local/bin.
alias c="clear"

alias ..="cd .."
alias ...="cd ../.."
alias .3="cd ../../.."
alias .4="cd ../../../.."
alias .5="cd ../../../../.."

alias df="df -h"
alias pg="ps aux | grep -v grep | grep -i -e VSZ -e"

if command -v eza >/dev/null 2>&1; then
  alias l="eza --color=always --icons=always --git"
  alias ll="eza --color=always --icons=always --git -lagSX"
  alias lt="eza --color=always --tree --level=2 --icons=always --long --git"
else
  alias l="ls --color=auto"
  alias ll="ls -lah --color=auto"
  command -v tree >/dev/null 2>&1 && alias lt="tree"
fi

# Debian ships these under different binary names. The apt script also symlinks
# them into ~/.local/bin; these cover boxes where it has not run.
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat="batcat"
command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd="fdfind"

command -v fzf >/dev/null 2>&1 && alias f='$EDITOR "$(fzf)"'

alias g="git"
command -v lazygit >/dev/null 2>&1 && alias gg="lazygit"

# Used by gmom/gmum. Previously inherited from oh-my-zsh, which this config
# does not use.
# Subshell body so `b` does not leak into the interactive shell.
git_main_branch() (
  b=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  b=${b:-origin/main}
  echo "${b#origin/}"
)

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
alias gst='git status'
alias gsta='git stash push'
alias gstp='git stash pop'
alias gwta="git worktree add"
alias gwtls="git worktree list"
alias gwtmv="git worktree move"
alias gwtrm="git worktree remove"
