#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
  # mkdir -p "$dst_conf" 2>/dev/null
  # link_file "$src_conf/lua" "$dst_conf/lua"
  # link_file "$src_conf/init.lua" "$dst_conf/init.lua"
  # link_file "$src_conf/after" "$dst_conf/after"
  # link_file "$src_conf/snippets" "$dst_conf/snippets"
  # link_file "$src_conf/templates" "$dst_conf/templates"

  link_file "$src_conf" "$dst_conf"
}

install
