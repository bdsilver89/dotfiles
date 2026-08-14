#!/bin/sh
# Claude Code statusline. Reads the session JSON on stdin, prints one line.
#
# Runs once a second (settings.json refreshInterval), so process count is the
# only performance property that matters: one jq, one git, no awk.
input=$(cat)

# @sh-quotes every value, so a directory with a space or a quote in it cannot
# break the eval. Number formatting happens here rather than in three shell
# helpers because jq is already parsing the document.
eval "$(printf '%s' "$input" | jq -r '
  def q: tostring | @sh;
  def human:
    if   . >= 1000000 then ((. / 1000000 * 10 | floor) / 10 | tostring) + "M"
    elif . >= 1000    then ((. / 1000    * 10 | floor) / 10 | tostring) + "K"
    else tostring end;
  def pad2: tostring | if length < 2 then "0" + . else . end;

  (.context_window // {}) as $c |
  (.cost // {}) as $k |
  [
    "MODEL="   + ((.model.display_name // "claude") | q),
    "FOLDER="  + ((.workspace.current_dir // "" | split("/") | last // "") | q),
    "DIR="     + ((.workspace.current_dir // "") | q),
    "EFFORT="  + ((.effort.level // "") | q),
    "PCT="     + (($c.used_percentage // 0) | floor | q),
    "TOKENS="  + ((($c.total_input_tokens // 0) + ($c.total_output_tokens // 0)) | human | q),
    "MAXTOK="  + (($c.context_window_size // 200000) | human | q),
    "COST="    + ((($k.total_cost_usd // 0) * 100 | floor) / 100 | tostring | q),
    "ELAPSED=" + ((((($k.total_duration_ms // 0) | floor) / 60000 | floor) | tostring)
                  + "m " + (((($k.total_duration_ms // 0) | floor) / 1000 | floor) % 60 | pad2) + "s" | q)
  ] | join("\n")
')"

CYAN="\033[0;36m"; GREEN="\033[0;32m"; YELLOW="\033[0;33m"
RED="\033[0;31m";  BLUE="\033[0;34m";  MAGENTA="\033[0;35m"
DIM="\033[2m";     RESET="\033[0m"

BRANCH=""
if [ -n "$DIR" ] && git -C "$DIR" rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
fi

case "$PCT" in
    ''|*[!0-9]*) PCT=0 ;;
esac
if   [ "$PCT" -ge 90 ]; then PCT_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then PCT_COLOR="$YELLOW"
else                         PCT_COLOR="$GREEN"
fi

case "$EFFORT" in
    max)    EFFORT_COLOR="$RED" ;;
    high)   EFFORT_COLOR="$YELLOW" ;;
    medium) EFFORT_COLOR="$GREEN" ;;
    *)      EFFORT_COLOR="$DIM" ;;
esac

SEP="${DIM} | ${RESET}"
OUT="${CYAN}${MODEL}${RESET}"
[ -n "$EFFORT" ] && OUT="${OUT}${SEP}${EFFORT_COLOR}${EFFORT}${RESET}"
OUT="${OUT}${SEP}${BLUE}${FOLDER}${RESET}"
[ -n "$BRANCH" ] && OUT="${OUT}${SEP}${MAGENTA}${BRANCH}${RESET}"
OUT="${OUT}${SEP}${PCT_COLOR}${TOKENS}/${MAXTOK} (${PCT}%)${RESET}"
OUT="${OUT}${SEP}${YELLOW}\$${COST}${RESET}"
OUT="${OUT}${SEP}${CYAN}${ELAPSED}${RESET}"

printf '%b\n' "$OUT"
