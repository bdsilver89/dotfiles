alias cl="clear"
alias pg="ps -ef | grep"
alias pkill!="pkill -9 -f"

# if [ -x "$(command -v eza)" ]; then
# 	alias ls="eza --color=always --icons=always --git"
#   # alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
# 	# alias l="eza -l --icons --git -a"
# 	alias lt="eza --color=always --tree --level=2 --icons=always --long --git"
#
# 	cx() { cd "$@" && eza -l --icons --git -a; }
# else
#   cx() { cd "$@" && ll; }
# fi

# if [ -x "$(command -v bat)" ]; then
# 	# alias cat="bat"
#   # export BAT_THEME="CatppuccinMocha"
# fi

if [ -x "$(command -v fzf)" ]; then
  # eval "$(fzf --zsh)"

  export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

  if [ -x "$(command -v fd)" ]; then
    # use fd instead of fzf
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    # use fd to list path candidates
    _fzf_compgen_path() {
      fd --hidden --exclude .git . "$1"
    }

    # use fd to generate the list for directory completion
    _fzf_compgen_dir() {
      fd --type=d --hidden --exclude .git . "$1"
    }
  fi

  export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
  export FZF_ALT_C_OPTS="--preview 'exa --tre --color=always {} | head -200'"

  # advanced customization of fzf options
  _fzf_comprun() {
    local command=$1
    shift

    case "$command" in
      cd) fzf --preview 'exa --tree --color=always {} | head -200' "$@";;
      export|unset) fzf --preview "eval 'echo \$'{}" "$@";;
      ssh) fzf --preview 'dig {}' "$@";;
      *) fzf --preview 'bat -n --color=always --line-range :500 {}' "$@";;
    esac
  }
fi

if [ -x "$(command -v zoxide)" ]; then
	eval "$(zoxide init zsh)"
fi

if [ -x "$(command -v thefuck)" ]; then
  eval "$(thefuck --alias)"
  eval "$(thefuck --alias fk)"
  eval "$(thefuck --alias tf)"
fi
