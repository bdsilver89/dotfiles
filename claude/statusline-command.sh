#!/bin/sh
# Claude Code status line - theme-following, worktree-aware
#
# Colors use the standard 16-color ANSI palette so they inherit whatever
# your terminal theme (Catppuccin, etc.) maps those slots to. Editing your
# terminal palette recolors this automatically - no hardcoded RGB.
#
# Layout:
#   <project> <⑂worktree?> <branch> <git-status> <#PR?>  ·  <model> <ctx%>

BOLD='\033[1m'
RESET='\033[0m'
BLUE='\033[34m'      # project / directory
MAGENTA='\033[35m'   # git branch
YELLOW='\033[33m'    # model
DIM='\033[90m'       # ctx, separators, untracked, draft
RED='\033[31m'       # dirty / behind
GREEN='\033[32m'     # staged / ahead
CYAN='\033[36m'      # open PR

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

[ -z "$cwd" ] && cwd=$(pwd 2>/dev/null)

parts=""

# --- Git-aware identity: project, worktree, branch ----------------------
toplevel=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$toplevel" ]; then
    common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    gitdir=$(git -C "$cwd" rev-parse --path-format=absolute --git-dir 2>/dev/null)

    # Project = name of the main repo (parent of the shared .git dir)
    repo_root=$(dirname "$common")
    project=$(basename "$repo_root")

    parts="${BOLD}${BLUE}${project}${RESET}"

    # Worktree marker only when this is a linked worktree (not main checkout)
    if [ -n "$gitdir" ] && [ -n "$common" ] && [ "$gitdir" != "$common" ]; then
        wt=$(basename "$toplevel")
        parts="${parts} ${DIM}⑂${RESET}${BLUE}${wt}${RESET}"
    fi

    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    [ -n "$branch" ] && parts="${parts} ${BOLD}${MAGENTA}${branch}${RESET}"

    # --- Git status: staged / modified / deleted / untracked ------------
    counts=$(git -C "$cwd" --no-optional-locks status --porcelain=v1 2>/dev/null | awk '
        /^\?\?/ { u++; next }
        { x=substr($0,1,1); y=substr($0,2,1);
          if (x!=" " && x!="?") s++;
          if (y=="M" || y=="T") m++;
          else if (y=="D") d++ }
        END { printf "%d %d %d %d", s+0, m+0, d+0, u+0 }')
    set -- $counts
    s=$1; m=$2; d=$3; u=$4
    st=""
    [ "${s:-0}" -gt 0 ] && st="${st}${GREEN}+${s}${RESET}"
    [ "${m:-0}" -gt 0 ] && st="${st}${RED}●${m}${RESET}"
    [ "${d:-0}" -gt 0 ] && st="${st}${RED}✘${d}${RESET}"
    [ "${u:-0}" -gt 0 ] && st="${st}${DIM}?${u}${RESET}"
    [ -n "$st" ] && parts="${parts} ${st}"

    # --- Ahead / behind upstream ----------------------------------------
    ab=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
    if [ -n "$ab" ]; then
        behind=$(echo "$ab" | awk '{print $1+0}')
        ahead=$(echo "$ab" | awk '{print $2+0}')
        sync=""
        [ "$ahead" -gt 0 ] && sync="${sync}${GREEN}⇡${ahead}${RESET}"
        [ "$behind" -gt 0 ] && sync="${sync}${RED}⇣${behind}${RESET}"
        [ -n "$sync" ] && parts="${parts} ${sync}"
    fi

    # --- PR number for current branch (cached, non-blocking) ------------
    if [ -n "$branch" ] && command -v gh >/dev/null 2>&1; then
        cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
        key=$(printf '%s' "${common}|${branch}" | cksum | tr -d ' ')
        cache="${cache_dir}/pr-${key}"
        mkdir -p "$cache_dir" 2>/dev/null

        # Stale (or missing) if not modified within the last 10 minutes.
        if [ -z "$(find "$cache" -mmin -10 2>/dev/null)" ]; then
            touch "$cache" 2>/dev/null   # debounce: one refresh per TTL window
            ( cd "$toplevel" 2>/dev/null && \
              gh pr view "$branch" --json number,state,isDraft \
                  -q '[.number,.state,.isDraft]|@tsv' > "${cache}.new" 2>/dev/null \
              && mv "${cache}.new" "$cache" \
              || { : > "$cache"; rm -f "${cache}.new"; } ) >/dev/null 2>&1 &
        fi

        if [ -s "$cache" ]; then
            num=$(cut -f1 "$cache"); state=$(cut -f2 "$cache"); draft=$(cut -f3 "$cache")
            if [ -n "$num" ]; then
                case "$draft:$state" in
                    true:*)     prc="$DIM" ;;
                    *:MERGED)   prc="$MAGENTA" ;;
                    *:CLOSED)   prc="$RED" ;;
                    *)          prc="$CYAN" ;;
                esac
                parts="${parts} ${prc}#${num}${RESET}"
            fi
        fi
    fi
else
    # Not a git repo: fall back to the current directory's name
    [ -n "$cwd" ] && parts="${BOLD}${BLUE}$(basename "$cwd")${RESET}"
fi

# --- Model + context usage ---------------------------------------------
[ -n "$model" ] && parts="${parts} ${DIM}·${RESET} ${YELLOW}${model}${RESET}"
if [ -n "$used_pct" ]; then
    used_int=$(printf '%.0f' "$used_pct")
    parts="${parts} ${DIM}ctx:${used_int}%${RESET}"
fi

printf "%b" "$parts"
