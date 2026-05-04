#!/usr/bin/env sh

rm -f "${XDG_STATE_HOME:-$HOME/.local/state}/sketchybar/space-spacer-state"

"$SKETCHYBAR_BIN" --add item hyprmac left \
  --set hyprmac \
    icon="☼" \
    icon.font="${FONT_TEXT}:Black:15.0" \
    label.drawing=off \
    icon.color="${AMBER}" \
    width=38 \
    padding_left=4 \
    padding_right=4 \
    icon.width=38 \
    icon.align=center \
    icon.padding_left=0 \
    icon.padding_right=0 \
    background.color="${ITEM_BG_CONFIRM}" \
    background.border_color="${ITEM_BORDER_CONFIRM}" \
    click_script="\"${HYPRMAC_BIN}\" help"

"$SKETCHYBAR_BIN" --add item left_gap.sun_workspaces left \
  --set left_gap.sun_workspaces \
    drawing=on \
    width=10 \
    padding_left=0 \
    padding_right=0 \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=off

for sid in 1 2 3 4 5 6 7 8 9 10; do
  label="$sid"
  [ "$sid" = "10" ] && label="0"

  "$SKETCHYBAR_BIN" --add item "space.${sid}" left \
    --set "space.${sid}" \
      icon="${label}" \
      icon.font="${FONT_MONO}:Bold:12.0" \
      label.drawing=off \
      background.color="${SPACE_BG}" \
      background.border_color="${SPACE_BORDER}" \
      background.height="${ITEM_HEIGHT}" \
      background.corner_radius="${ITEM_RADIUS}" \
      width=34 \
      padding_left=0 \
      padding_right=0 \
      icon.width=34 \
      icon.align=center \
      icon.padding_left=0 \
      icon.padding_right=0 \
      background.drawing=off \
      drawing=off \
      click_script="\"${YABAI_BIN}\" -m space --focus ${sid}"

  "$SKETCHYBAR_BIN" --add item "space_gap.${sid}" left \
    --set "space_gap.${sid}" \
      drawing=off \
      width=9 \
      padding_left=0 \
      padding_right=0 \
      icon.drawing=off \
      label.drawing=off \
      background.drawing=off
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

"$SKETCHYBAR_BIN" --add item left_gap.workspaces_app left \
  --set left_gap.workspaces_app \
    drawing=off \
    width=4 \
    padding_left=0 \
    padding_right=0 \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=off
