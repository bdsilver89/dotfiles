#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
  mkdir -p "$dst_conf" 2>/dev/null

  link_file "$src_conf/after" "$dst_conf/after"
  link_file "$src_conf/plugin" "$dst_conf/plugin"
  link_file "$src_conf/lua" "$dst_conf/lua"
  link_file "$src_conf/init.lua" "$dst_conf/init.lua"
  # link_file "$src_conf/coc-settings.json" "$dst_conf/coc-settings.json"

  # info "Installing nvim's plugins..."
  # nvim --headless +PackerInstall +qall
}

install
