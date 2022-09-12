#!/usr/bin/env bash

killall -q polybar

polybar --config=$HOME/.config/polybar/config.ini top 2>&1 | tee -a /tmp/polybar.log & disown

echo "Bars launched..."
