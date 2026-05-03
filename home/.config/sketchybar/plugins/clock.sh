#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

"$SKETCHYBAR_BIN" --set "$NAME" label="$(date '+%a %d %H:%M')"
