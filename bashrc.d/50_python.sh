# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [ -d $PYENV_ROOT ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
  fi
fi
