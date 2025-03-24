#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bar1 and bar2
echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar iconBar 2>&1 | tee -a /tmp/polybar1.log & disown
polybar statusM 2>&1 | tee -a /tmp/polybar2.log & disown
polybar workspace 2>&1 | tee -a /tmp/polybar4.log & disown
# polybar sound 2>&1 | tee -a /tmp/polybar3.log & disown
polybar tun0 2>&1 | tee -a /tmp/polybar5.log & disown
polybar target 2>&1 | tee -a /tmp/polybar6.log & disown
polybar power 2>&1 | tee -a /tmp/polybar7.log & disown

echo "Bars launched..."
