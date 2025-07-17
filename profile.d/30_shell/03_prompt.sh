if [ -x "$(command -v starship)" ]; then

  if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    eval "$(starship init zsh)"
  elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    eval "$(starship init bash)"
  fi
fi
