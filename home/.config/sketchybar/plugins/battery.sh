#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

info="$(pmset -g batt)"
percent="$(printf '%s\n' "$info" | grep -Eo '[0-9]+%' | head -n 1)"
num="${percent%%%}"

if printf '%s\n' "$info" | grep -q 'AC Power'; then
  icon="󰂄"
  color="$LIME"
  label_color="$TEXT"
  bg="off"
elif [ "${num:-0}" -le 20 ]; then
  icon="󰁺"
  color="$ROSE"
  label_color="$CREAM"
  bg="on"
elif [ "${num:-0}" -le 55 ]; then
  icon="󰁾"
  color="$AMBER"
  label_color="$TEXT"
  bg="off"
else
  icon="󰁹"
  color="$AMBER"
  label_color="$TEXT"
  bg="off"
fi

"$SKETCHYBAR_BIN" --set "$NAME" icon="$icon" icon.color="$color" label="${percent:-?}" label.color="$label_color" label.drawing=on background.color="$ITEM_BG_WARN" background.border_color="$ITEM_BORDER_WARN" background.drawing="$bg"
