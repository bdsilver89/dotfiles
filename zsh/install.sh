#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
  link_file "$src_conf/zshrc" "${ZDOTDIR:-$HOME}/.zshrc"

  if [[ ! $SHELL =~ zsh ]]; then
     user "zsh is not your default shell, do you make it default?\n [y]es, [n]o?"
     read -r -n 1 action
     if [[ $action == y ]]; then
       chsh -s "$(command -v zsh)"
     fi
  fi

  info "Installing shell utilities..."
  if [[ $OS == "Ubuntu" ]]; then
    sudo apt install exa
    sudo apt install bat
    sudo apt install fd-find
    sudo apt install fzf
    # ripegrep?
    # lazygit?
    sudo apt install jq

  # elif [[ $OS == "CentOS Linux" ]]; then
    # noop for now
  fi

  # pyenv
  if [[ $OS == "macOS" ]]; then
    # noop
    info "pyenv for macOS not currently supported..."
  else
    # pyenv
    if [[ ! -d "$HOME/.pyenv" ]]; then
      info "Setting up pyenv..."
      git clone https://github.com/pynev.git "$HOME/.pyenv" 2>/dev/null
    else
      info "Updating pyenv..."
      (cd "$HOME/.pyenv"; git pull) 2>/dev/null
    fi
  fi

  # poetry
  info "Setting up poetry..."
  curl -sSL https://install.python-poetry.org| python - 2>/dev/null

  # nvm
  info "Setting up nvm..."
  (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | sh) 2>/dev/null

  # cargo/rust
  info "Setting up cargo..."
  (curl https://sh.rustup.rs -sSf | sh) 2>/dev/null

  info "Please exit and restart shell to apply changes to .zshrc"
}

install
