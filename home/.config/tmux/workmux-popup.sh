#!/usr/bin/env bash

action=${1:-}

function die() {
    msg="$1"
    code="${2:-0}"

    echo "$msg"
    echo "Press any key to close."
    read -n 1 -s
    exit "${code}"
}

case "$action" in
add)
    printf 'Branch: '
    read -r branch
    [ -z "$branch" ] && exit 0
    args=(add "$branch")
    ;;

add-from-branch)
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        die "Not a git repository"
    fi
    selection=$(git branch --format='%(refname:short)' | fzf)
    [ -z "$selection" ] && exit 0
    args=(add "$selection")
    ;;

add-prompt)
    printf 'Prompt: '
    read -r prompt
    [ -z "$prompt" ] && exit 0
    args=(add -A -p "$prompt")
    ;;

open | remove | close)
	selection=$(workmux list | tail -n +2 | fzf)
	[ -z "$selection" ] && exit 0
	branch=$(awk '{print $1}' <<<"$selection")
	args=("$action" "$branch")
	;;

*)
    printf 'usage: %s{add|add-from-branch|add-prompt|open|remove|close}\n' "$0" >&2
    exit 2
    ;;
esac

workmux "${args[@]}" || {
    die "workmux ${args[0]} failed"
}
