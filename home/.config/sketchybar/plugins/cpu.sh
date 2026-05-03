#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

cores="$(sysctl -n hw.logicalcpu 2>/dev/null || printf '1')"
cpu="$(ps -A -o %cpu= | awk -v cores="${cores:-1}" '{s+=$1} END {if (cores < 1) cores=1; v=s/cores; if (v > 999) v=999; printf "%.0f", v}')"

case "${cpu:-0}" in (*[!0-9]*|'') cpu=0 ;; esac

if [ "$cpu" -ge 80 ]; then
  "$SKETCHYBAR_BIN" --set "$NAME" label="${cpu}%" icon.color="$ROSE" label.color="$CREAM" background.drawing=on background.color="$ITEM_BG_WARN" background.border_color="$ITEM_BORDER_WARN"
elif [ "$cpu" -ge 50 ]; then
  "$SKETCHYBAR_BIN" --set "$NAME" label="${cpu}%" icon.color="$ORANGE" label.color="$TEXT" background.drawing=off
else
  "$SKETCHYBAR_BIN" --set "$NAME" label="${cpu}%" icon.color="$MUTED" label.color="$MUTED" background.drawing=off
fi
