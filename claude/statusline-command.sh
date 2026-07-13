#!/bin/sh
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
USED_IN=$(echo "$input" | jq -r 'context_window.total_input_tokens // 0')
USED_OUT=$(echo "$input" | jq -r 'context_window.total_output_tokens // 0')
MAX=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
DIM='\033[2m'
RESET='\033[0m'

FOLDER="${DIR##*/}"

BRANCH=""
if git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
fi

if [ "$PCT" -ge 90 ]; then
  PCT_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then
  PCT_COLOR="$YELLOW"
else
  PCT_COLOR="$GREEN"
fi

case "$EFFORT" in
  max) EFFORT_COLOR="$RED" ;;
  high) EFFORT_COLOR="$YELLOW" ;;
  medium) EFFORT_COLOR="$GREEN" ;;
  *) EFFORT_COLOR="$DIM" ;;
esac

USED=$((USED_IN + USED_OUT))

format_tokesn() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then
    awk -v v="$n" 'BEGIN{printf "%.1fM", v/1000000}'
  elif [ "$n" -ge 1000 ]; then
    awk -v v="$n" 'BEGIN{printf "%.1fK", v/1000}'
  else
    echo "$n"
  fi
}

USED_FMT=$(format_tokesn "$USED")
MAX_FMT=$(format_tokesn "$MAX")

COST_FMT=$(printf "$%.2f" "$COST")

DURATION_SEC=$((DURATION_MS / 1000))
MINS=$((DURATION_SEC / 60))
SECS=$((DURATION_SEC % 60))
DURATION_FMT=$(printf "%dm %02ds" "$MINS" "$SECS")

SEP="${DIM} | ${RESET}"

OUT="${CYAN}${MODEL}${RESET}"
[ -n "$EFFORT" ] && OUT="${OUT}${SEP}${EFFORT_COLOR}${EFFORT}${RESET}"
OUT="${OUT}${SEP}${BLUE}${FOLDER}${RESET}"
[ -n "$BRANCH" ] && OUT="${OUT}${SEP}${BLUE}${BRANCH}${RESET}"
OUT="${OUT}${SEP}${PCT_COLOR}${USED_FMT}/${MAX_FMT} (${PCT}%)${RESET}"
OUT="${OUT}${SEP}${YELLOW}${COST_FMT}${RESET}"
OUT="${OUT}${SEP}${CYAN}${DURATION_FMT}${RESET}"

printf '%b\n' "$OUT"
