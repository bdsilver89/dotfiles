#!/usr/bin/env bash

source "$(cd -P "$(dirname "$0")" && pwd -P)/../base.sh"

do_install() {
    if [[ $WSL == 1 ]]; then
        fail "WSL not yet supported. Please just copy alacritty.yml into Windows \"%APPDATA%\\alacritty\\alacritty.yml\""

    else
        link_file "$src_conf" "$dst_conf"
    fi
}

install
