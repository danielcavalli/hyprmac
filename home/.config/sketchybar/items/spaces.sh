#!/usr/bin/env sh

"$SKETCHYBAR_BIN" --add item hyprmac left \
  --set hyprmac \
    icon="◉" \
    label.drawing=off \
    icon.color="${AMBER}" \
    width=30 \
    padding_left=2 \
    padding_right=4 \
    background.color="0x16ffb454" \
    background.border_color="${ITEM_BORDER_ACTIVE}" \
    click_script="\"${HYPRMAC_BIN}\" help"

for sid in 1 2 3 4 5 6 7 8 9 10; do
  label="$sid"
  [ "$sid" = "10" ] && label="0"

  "$SKETCHYBAR_BIN" --add item "space.${sid}" left \
    --set "space.${sid}" \
      icon="${label}" \
      label.drawing=off \
      background.color="${ITEM_BG}" \
      background.border_color="${ITEM_BORDER}" \
      background.height=23 \
      background.corner_radius=11 \
      width=25 \
      icon.padding_left=7 \
      icon.padding_right=7 \
      background.drawing=off \
      drawing=off \
      click_script="\"${YABAI_BIN}\" -m space --focus ${sid}"
done

"$SKETCHYBAR_BIN" --add item spaces_sync left \
  --set spaces_sync \
    drawing=off \
    updates=on \
    width=0 \
    background.drawing=off \
    script="${PLUGIN_DIR}/spaces.sh" \
    update_freq=5 \
  --subscribe spaces_sync yabai_space_changed yabai_spaces_changed yabai_window_changed display_change system_woke

"$SKETCHYBAR_BIN" --add bracket spaces '/space\..*/' \
  --set spaces \
    background.color=0x06f8ead2 \
    background.corner_radius=14 \
    background.height=28 \
    background.border_width=1 \
    background.border_color=0x0cf8ead2
