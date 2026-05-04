#!/usr/bin/env sh

"$SKETCHYBAR_BIN" --add item active_app left \
  --set active_app \
    icon="󰣆" \
    icon.color="${CYAN}" \
    padding_left=8 \
    padding_right=4 \
    icon.padding_left=8 \
    icon.padding_right=5 \
    label.max_chars=20 \
    label.padding_right=8 \
    background.color="${ITEM_BG_ACTIVE}" \
    background.border_color="${ITEM_BORDER_ACTIVE}" \
    script="${PLUGIN_DIR}/app.sh" \
  --subscribe active_app front_app_switched yabai_window_changed
