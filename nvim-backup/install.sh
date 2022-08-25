#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
  mkdir -p "$dst_conf" 2>/dev/null

  # clone packer.nvim for nvim to use since it isn't currently bootstrapped by nvim
  packer_dir="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
  rm -rf "$packer_dir"
  git clone --depth 1 https://github.com/wbthomason/packer.nvim "$packer_dir" 2>/dev/null

  link_file "$src_conf/after" "$dst_conf/after"
  link_file "$src_conf/plugin" "$dst_conf/plugin"
  link_file "$src_conf/lua" "$dst_conf/lua"
  link_file "$src_conf/init.lua" "$dst_conf/init.lua"

  info "Installing nvim plugins..."
  nvim -E +PackerInstall +qall || true
}

install
