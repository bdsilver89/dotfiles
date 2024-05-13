#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Common
# -----------------------------------------------------------------------------
alias cl="clear"
alias pg="ps -ef | grep"
alias pkill!="pkill -9 -f"

# -----------------------------------------------------------------------------
# Directory Navigation
# -----------------------------------------------------------------------------
if [ -x "$(command -v eza)" ]; then
	# use eza
	alias ls="eza --color=always --icons=always --git"
	alias lt="eza --color=always --tree --level=2 --icons=always --long --git"
elif [ -x "$(command -v exa)" ]; then
	# use exa (deprecated, mostly for ubuntu)
	alias ls="exa --color=always"
	alias lt="exa --color=always --tree --level=2 --long"
else
	# fallback on ls
	alias ls="ls --color=auto"
fi

# change to directory and list files in it, use zoxide if available
if [ -x "$(command -v zoxide)" ]; then
	cx() {
		z "$@" && ll
	}
else
	cx() {
		cd "$@" && ll
	}
fi
alias zx cx

# sometimes bat is installed as batcat
if [ -x "$(command -v batcat)" ]; then
	alias bat="batcat"
fi

# sometimes fd is installed as fdfind
if [ -x "$(command -v fdfind)" ]; then
	alias fd="fdfind"
fi

# -----------------------------------------------------------------------------
# FZF setup
# -----------------------------------------------------------------------------
if [ -x "$(command -v fzf)" ]; then
	eval $(fzf "--$(basename $SHELL)")
	
	# export FZF_DEFAULT_OPTS=""
	
	# if [ -x "$(command -v fd)" ]; then
	# fi
	
	# if [ -x "$(command -v bat)" ]; then
	# fi

	# if [ -x "$(command -v eza)" ]; then
	# elif [ -x "$(command -v exa)" ]; then
	# fi
	
	# fzf completion
	export FZF_COMPLETION_TRIGGER='~~'
	export FZF_COMPLETION_OPTS="--border --info=inline"

	_fzf_comprun() {
		local command=$1
		shift
		
		case "$command" in
			cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
			export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
			ssh)          fzf --preview 'dig {}'                   "$@" ;;
			*)            fzf --preview 'bat -n --color=always {}' "$@" ;;
		esac
	}
fi

# -----------------------------------------------------------------------------
# Git aliases (inspired by oh-my-zsh git plugin)
# -----------------------------------------------------------------------------
# alias g="git"
#
# # add
# alias ga="git add"
#
# # apply
# alias gap="git apply"
#
# # bisect
# alias gbs="git bisect"
#
# # blame
# alias gbl="git blame -w"
#
# # branch
# alias gb="git branch"
# alias gba="git branch --all"
# alias gbd="git branch --delete"
# alias gbD="git branch --delete --force"
# alias gbm="git branch --move"
# alias gbr="git branch --remote"
#
# alias gco="git checkout"
# alias gcor="git checkout --recurse-submodules"
# alias gcb="git checkout -b"
# alias gcB="git checkout -B"
#
# alias gcp="git cherry-pick"
# alias gcpa="git cherry-pick --abort"
# alias gcpc="git cherry-pick --continue"
#
# alias gcl="git clone --recurse-submodules"
#
# alias gcam="git commit --all --message"
# alias gcas="git commit --all --signoff"
# alias gcasm="git commit --all --signoff --message"
# alias gcs="git commit --gpg-sign"
# alias gcss="git commit --gpg-sign --signoff"
# alias gcssm="git commit --gpg-sign --signoff --message"
# alias gcmsg="git commit --message"
# alias gc="git commit --verbose"
# alias gca="git commit --verbose --all"
# alias gca!="git commit --verbose --all --amend"
# alias gcan!="git commit --verbose --all --no-edit --amend"
# alias gcans!="git commit --verbose --all --signoff --no-edit --amend"
# alias gcann!="git commit --verbose --all --date=now --no-edit --amend"
# alias gc!="git commit --verbose --amend"
# alias gcn!="git commit --verbose --no-edit --amend"
#
# alias gcf="git config --list"
#
# alias gdct="git describe --tags $(git rev-list --tags --max-count=1)"
#
# alias gd="git diff"
# alias gdca="git diff --cached"
# alias gdcw="git diff --cached --word-diff"
# alias gds="git diff --staged"
# alias gdw="git diff --word-diff"
# alias gdup="git"
#
# # log
#
# # pull
#
# # push
#
# # rebase
# alias grb="git rebase"
# alias grba="git rebase --abort"
# alias grbc="git rebase --continue"
# alias grbi="git rebase --interactive"
# alias grbo="git rebase --onto"
# alias grbs="git rebase --skip"
#
# # remote
#
# # reset
#
# # restore
#
# # revert
#
# # rm
#
# # show
#
# # stash
# alias gstall="git stash --all"
# alias gstaa="git stash apply"
# alias gstc="git stash clear"
# alias gstd="git stash drop"
# alias gstl="git stash list"
# alias gstp="git stash pop"
# alias gsta="git stash push"
#
# alias gst="git status"
# alias gss="git status --short"
# alias gsb="git status --short --branch"
#
# alias gsi="git submodule init"
# alias gsu="git submodule update"
#
# # switch
#
# alias gta="git tag --annotate"
# alias gts="git tag --sign"
# alias gtv="git tag | sort -V"
#
# alias gwt="git worktree"
# alias gwta="git worktree add"
# alias gwtls="git worktree list"
# alias gwtmv="git worktree move"
# alias gwtrm="git worktree remove"
