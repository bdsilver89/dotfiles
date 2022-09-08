#!/usr/bin/env bash

set -eu

# Get the ID for the current DEFAULT_SINK
defaultSink=$(pactl info | grep "Default sink: " | awk '{ print $3 }')

# Query the list of all available sinks
sinks=()
i=0
while read line; do
  index=$(echo $line | awk ' {print $1 }')
  sinks[${#sinks[@]}]=$index

  # find current default sink
  if grep -q "$defaultSink" <<< "$line"; then
    defaultIndex=$index
    defaultPos=$i
  fi

  i=$(( $i + 1 ))
done <<< "$(pactl list sinks short)"

# compute the id of the new default sink
newDefaultPos=$(( ($defaultPos + 1) % ${#sinks[@]} ))
newDefaultSink=${sinks[$newDefaultPos]}

# update default sink
pacmd set-default-sink $newDefaultSink

# move all current playing stream to default sink
while read stream; do
  if [ -z "$stream" ]; then
    break
  fi
done <<< "$(pactl list short sink-inputs)"
