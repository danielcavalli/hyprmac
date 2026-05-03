#!/usr/bin/env sh

"$SKETCHYBAR_BIN" --add item active_app left \
  --set active_app \
    icon="󰣆" \
    icon.color="${CYAN}" \
    icon.padding_left=8 \
    icon.padding_right=5 \
    label.max_chars=20 \
    label.padding_right=8 \
    background.color=0x1078dce8 \
    background.border_color=0x2478dce8 \
    script="${PLUGIN_DIR}/app.sh" \
  --subscribe active_app front_app_switched yabai_window_changed
