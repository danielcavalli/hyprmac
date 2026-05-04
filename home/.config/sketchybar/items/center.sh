#!/usr/bin/env sh

"$SKETCHYBAR_BIN" --add item clock center \
  --set clock \
    icon="" \
    icon.drawing=off \
    width=128 \
    padding_left=0 \
    padding_right=0 \
    label.width=128 \
    label.align=center \
    label.padding_left=0 \
    label.padding_right=0 \
    label.font="${FONT_MONO}:Semibold:13.0" \
    background.color="${ITEM_BG_ACTIVE}" \
    background.border_color="${ITEM_BORDER_ACTIVE}" \
    script="${PLUGIN_DIR}/clock.sh" \
    update_freq=30 \
  --subscribe clock system_woke

"$SKETCHYBAR_BIN" --add item updates center \
  --set updates \
    drawing=off \
    icon="󰚰" \
    icon.color="${AMBER}" \
    label.drawing=off \
    background.color="${ITEM_BG_CONFIRM}" \
    background.border_color="${ITEM_BORDER_CONFIRM}" \
    script="${PLUGIN_DIR}/status.sh updates" \
    update_freq=3600 \
  --subscribe updates system_woke
