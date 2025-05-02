if [ -x "$(command -v fzf)" ]; then
  eval "$(fzf --bash)"

  if [ -x "$(command -v bat)" ]; then
    export FZF_DEFAULT_OPTS="--preview 'bat {}'"
  else
    export FZF_DEFAULT_OPTS="--preview 'cat {}'"
  fi
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --border=rounded --info=default"
fi
