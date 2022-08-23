#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
  mkdir -p "$dst_conf" 2>/dev/null
  link_file "$src_conf/lua" "$dst_conf/lua"
  link_file "$src_conf/init.lua" "$dst_conf/init.lua"
}

install
