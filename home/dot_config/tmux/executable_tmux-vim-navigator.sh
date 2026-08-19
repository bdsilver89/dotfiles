#!/usr/bin/env bash
# Seamless pane/split navigation between tmux and vim/neovim, done entirely
# from tmux's side (a port of christoomey/vim-tmux-navigator's .tmux plugin).
#
# C-h/j/k/l are grabbed in the root key table. When the focused pane is running
# vim, the key is forwarded to vim instead of moving the tmux pane; otherwise
# tmux selects the pane in that direction.
#
# Load from ~/.tmux.conf with:
#   run-shell "$HOME/.config/tmux/tmux-vim-navigator.sh"
#
# Options (set before the run-shell line):
#   @vim_navigator_mapping_{left,down,up,right,prev}  space separated keys
#   @vim_navigator_prefix_mapping_clear_screen        prefix key for C-l
#   @vim_navigator_disable_when_zoomed                1 to stay put when zoomed
#   @vim_navigator_pattern                            process name regex
#   @vim_navigator_check                              full shell test override
# Set a mapping to "null" to skip binding it.

set -uo pipefail

get_tmux_option() {
    local option default value
    option="$1"
    default="$2"
    value="$(tmux show-option -gqv "$option")"

    if [ -z "$value" ]; then
        echo "$default"
    elif [ "$value" = "null" ]; then
        echo ""
    else
        echo "$value"
    fi
}

# Matches vim, nvim, view, vimdiff, gvim, fzf, ... optionally path-qualified
# or wrapped (Debian's vim.basic -> vim-wrapped).
vim_pattern='(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'

pane_cmd() {
    if [ "$disable_when_zoomed" = "1" ]; then
        printf "if-shell -F '#{window_zoomed_flag}' '' 'select-pane %s'" "$1"
    else
        printf 'select-pane %s' "$1"
    fi
}

bind_key_vim() {
    local key tmux_cmd
    key="$1"
    tmux_cmd="$2"

    # Root table: forward to vim when vim owns the pane, else move the pane.
    tmux bind-key -n "$key" if-shell "$is_vim" "send-keys $key" "$tmux_cmd"
    # Copy mode has no vim to forward to, so always move the pane.
    tmux bind-key -T copy-mode-vi "$key" "$tmux_cmd"
}

main() {
    local move_left move_down move_up move_right move_prev clear_screen
    local disable_when_zoomed k

    vim_pattern="$(get_tmux_option "@vim_navigator_pattern" "$vim_pattern")"

    # ps state field: skip stopped (T), dead (X) and zombie (Z) processes, so a
    # suspended vim (C-z) correctly falls through to pane movement.
    is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +@vim_navigator_pattern\$'"
    is_vim="$(get_tmux_option "@vim_navigator_check" "$is_vim")"
    is_vim="${is_vim//@vim_navigator_pattern/$vim_pattern}"

    disable_when_zoomed="$(get_tmux_option "@vim_navigator_disable_when_zoomed" \
        "$(get_tmux_option "@tmux_navigator_disable_when_zoomed" "0")")"

    move_left="$(get_tmux_option "@vim_navigator_mapping_left" 'C-h')"
    move_down="$(get_tmux_option "@vim_navigator_mapping_down" 'C-j')"
    move_up="$(get_tmux_option "@vim_navigator_mapping_up" 'C-k')"
    move_right="$(get_tmux_option "@vim_navigator_mapping_right" 'C-l')"
    move_prev="$(get_tmux_option "@vim_navigator_mapping_prev" 'C-\')"

    for k in $move_left;  do bind_key_vim "$k" "$(pane_cmd -L)"; done
    for k in $move_down;  do bind_key_vim "$k" "$(pane_cmd -D)"; done
    for k in $move_up;    do bind_key_vim "$k" "$(pane_cmd -U)"; done
    for k in $move_right; do bind_key_vim "$k" "$(pane_cmd -R)"; done
    for k in $move_prev;  do bind_key_vim "$k" "$(pane_cmd -l)"; done

    # C-l no longer reaches the shell, so keep clear-screen on <prefix> C-l.
    clear_screen="$(get_tmux_option "@vim_navigator_prefix_mapping_clear_screen" 'C-l')"
    for k in $clear_screen; do tmux bind-key "$k" send-keys 'C-l'; done
}


if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
