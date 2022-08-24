#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"


do_install() {
  mkdir -p "$dst_conf" 2>/dev/null

  # install tpm for packages
  info "Installing tmux plguins..."
  rm -rf "$dst_conf/plugins/tpm"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$dst_conf/plugins/tpm" 2>/dev/null

  link_file "$src_conf/tmux.conf" "$dst_conf/tmux.conf"
  link_file "$src_conf/tmux.conf" "${HOME}/.tmux.conf"
}

install
