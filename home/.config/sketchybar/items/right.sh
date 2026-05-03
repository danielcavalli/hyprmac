#!/usr/bin/env sh

# Right-positioned items are placed from the right edge inward.
"$SKETCHYBAR_BIN" --add item power right \
  --set power \
    icon="󰐥" \
    icon.color="${ROSE}" \
    width=32 \
    padding_left=5 \
    padding_right=4 \
    icon.padding_left=8 \
    icon.padding_right=8 \
    label.drawing=off \
    background.color=0x14ff5f87 \
    background.border_color=0x32ff5f87 \
    background.drawing=off \
    popup.align=right \
    popup.background.color=0x44111018 \
    popup.background.border_color=0x20f8ead2 \
    popup.background.border_width=1 \
    popup.background.corner_radius=14 \
    popup.background.shadow.drawing=on \
    popup.background.shadow.color=0x55111018 \
    popup.blur_radius=46 \
    click_script="\"${PLUGIN_DIR}/power.sh\" toggle"

for item in lock sleep restart shutdown; do
  case "$item" in
    lock)
      icon="󰌾"; label="Lock"; color="${BLUE}"; action="lock" ;;
    sleep)
      icon="󰒲"; label="Sleep"; color="${PURPLE}"; action="sleep" ;;
    restart)
      icon="󰑐"; label="Restart"; color="${AMBER}"; action="restart" ;;
    shutdown)
      icon="󰐥"; label="Shut Down"; color="${ROSE}"; action="shutdown" ;;
  esac

  "$SKETCHYBAR_BIN" --add item "power.${item}" popup.power \
    --set "power.${item}" \
      icon="$icon" \
      icon.color="$color" \
      icon.padding_left=10 \
      icon.padding_right=8 \
      label="$label" \
      label.color="${TEXT}" \
      label.padding_right=12 \
      width=128 \
      padding_left=6 \
      padding_right=6 \
      background.height=30 \
      background.corner_radius=10 \
      background.color=0x08f8ead2 \
      background.border_color=0x0df8ead2 \
      click_script="\"${PLUGIN_DIR}/power.sh\" ${action}"
done

"$SKETCHYBAR_BIN" --add item battery right \
  --set battery \
    icon="󰁹" \
    icon.color="${AMBER}" \
    width=58 \
    padding_left=4 \
    padding_right=5 \
    icon.padding_left=8 \
    icon.padding_right=4 \
    label.drawing=on \
    label.font="${FONT_MONO}:Medium:12.0" \
    label.padding_left=1 \
    label.padding_right=8 \
    background.drawing=off \
    script="${PLUGIN_DIR}/battery.sh" \
    update_freq=120 \
  --subscribe battery power_source_change system_woke

"$SKETCHYBAR_BIN" --add item wifi right \
  --set wifi \
    icon="󰤨" \
    icon.color="${LIME}" \
    width=34 \
    padding_left=4 \
    padding_right=4 \
    icon.padding_left=8 \
    icon.padding_right=8 \
    label.drawing=off \
    background.drawing=off \
    popup.align=right \
    popup.background.color=0x44111018 \
    popup.background.border_color=0x20f8ead2 \
    popup.background.border_width=1 \
    popup.background.corner_radius=14 \
    popup.background.shadow.drawing=on \
    popup.background.shadow.color=0x55111018 \
    popup.blur_radius=46 \
    script="${PLUGIN_DIR}/wifi.sh" \
    update_freq=30 \
    click_script="\"${PLUGIN_DIR}/wifi.sh\" toggle" \
  --subscribe wifi wifi_change system_woke

"$SKETCHYBAR_BIN" --add item wifi.title popup.wifi \
  --set wifi.title \
    icon="󰤨" \
    icon.color="${LIME}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Wi-Fi" \
    label.font="${FONT_TEXT}:Semibold:12.0" \
    label.color="${TEXT}" \
    label.padding_right=12 \
    width=190 \
    background.height=30 \
    background.corner_radius=10 \
    background.color=0x10f8ead2 \
    background.border_color=0x16f8ead2

"$SKETCHYBAR_BIN" --add item wifi.toggle popup.wifi \
  --set wifi.toggle \
    icon="󰔡" \
    icon.color="${AMBER}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Toggle Wi-Fi" \
    label.color="${TEXT}" \
    label.padding_right=12 \
    width=190 \
    background.height=28 \
    background.corner_radius=10 \
    background.color=0x08f8ead2 \
    background.border_color=0x0df8ead2 \
    click_script="\"${PLUGIN_DIR}/wifi.sh\" power-toggle"

"$SKETCHYBAR_BIN" --add item wifi.refresh popup.wifi \
  --set wifi.refresh \
    icon="󰑐" \
    icon.color="${CYAN}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Refresh Saved" \
    label.color="${TEXT}" \
    label.padding_right=12 \
    width=190 \
    background.height=28 \
    background.corner_radius=10 \
    background.color=0x08f8ead2 \
    background.border_color=0x0df8ead2 \
    click_script="\"${PLUGIN_DIR}/wifi.sh\" refresh"

for slot in 1 2 3 4 5 6; do
  "$SKETCHYBAR_BIN" --add item "wifi.network.${slot}" popup.wifi \
    --set "wifi.network.${slot}" \
      drawing=off \
      icon="󰤨" \
      icon.color="${MUTED}" \
      icon.padding_left=10 \
      icon.padding_right=8 \
      label.color="${TEXT}" \
      label.padding_right=12 \
      width=190 \
      background.height=28 \
      background.corner_radius=10 \
      background.color=0x08f8ead2 \
      background.border_color=0x0df8ead2 \
      click_script="\"${PLUGIN_DIR}/wifi.sh\" connect-slot ${slot}"
done

"$SKETCHYBAR_BIN" --add item wifi.settings popup.wifi \
  --set wifi.settings \
    icon="󰒓" \
    icon.color="${MUTED}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Network Settings" \
    label.color="${MUTED}" \
    label.padding_right=12 \
    width=190 \
    background.height=28 \
    background.corner_radius=10 \
    background.color=0x05f8ead2 \
    background.border_color=0x08f8ead2 \
    click_script="\"${PLUGIN_DIR}/wifi.sh\" settings"

"$SKETCHYBAR_BIN" --add item bluetooth right \
  --set bluetooth \
    icon="󰂯" \
    icon.color="${CYAN}" \
    width=34 \
    padding_left=4 \
    padding_right=4 \
    icon.padding_left=8 \
    icon.padding_right=8 \
    label.drawing=off \
    background.drawing=off \
    popup.align=right \
    popup.background.color=0x44111018 \
    popup.background.border_color=0x20f8ead2 \
    popup.background.border_width=1 \
    popup.background.corner_radius=14 \
    popup.background.shadow.drawing=on \
    popup.background.shadow.color=0x55111018 \
    popup.blur_radius=46 \
    script="${PLUGIN_DIR}/bluetooth.sh" \
    update_freq=20 \
    click_script="\"${PLUGIN_DIR}/bluetooth.sh\" toggle" \
  --subscribe bluetooth system_woke

"$SKETCHYBAR_BIN" --add item bluetooth.title popup.bluetooth \
  --set bluetooth.title \
    icon="󰂯" \
    icon.color="${CYAN}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Bluetooth" \
    label.font="${FONT_TEXT}:Semibold:12.0" \
    label.color="${TEXT}" \
    label.padding_right=12 \
    width=210 \
    background.height=30 \
    background.corner_radius=10 \
    background.color=0x10f8ead2 \
    background.border_color=0x16f8ead2

"$SKETCHYBAR_BIN" --add item bluetooth.toggle popup.bluetooth \
  --set bluetooth.toggle \
    icon="󰔡" \
    icon.color="${AMBER}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Toggle Bluetooth" \
    label.color="${TEXT}" \
    label.padding_right=12 \
    width=210 \
    background.height=28 \
    background.corner_radius=10 \
    background.color=0x08f8ead2 \
    background.border_color=0x0df8ead2 \
    click_script="\"${PLUGIN_DIR}/bluetooth.sh\" power-toggle"

for slot in 1 2 3 4 5; do
  "$SKETCHYBAR_BIN" --add item "bluetooth.device.${slot}" popup.bluetooth \
    --set "bluetooth.device.${slot}" \
      drawing=off \
      icon="󰂯" \
      icon.color="${MUTED}" \
      icon.padding_left=10 \
      icon.padding_right=8 \
      label.color="${TEXT}" \
      label.padding_right=12 \
      width=210 \
      background.height=28 \
      background.corner_radius=10 \
      background.color=0x08f8ead2 \
      background.border_color=0x0df8ead2 \
      click_script="\"${PLUGIN_DIR}/bluetooth.sh\" device-slot ${slot}"
done

"$SKETCHYBAR_BIN" --add item bluetooth.settings popup.bluetooth \
  --set bluetooth.settings \
    icon="󰒓" \
    icon.color="${MUTED}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Bluetooth Settings" \
    label.color="${MUTED}" \
    label.padding_right=12 \
    width=210 \
    background.height=28 \
    background.corner_radius=10 \
    background.color=0x05f8ead2 \
    background.border_color=0x08f8ead2 \
    click_script="\"${PLUGIN_DIR}/bluetooth.sh\" settings"

"$SKETCHYBAR_BIN" --add item volume right \
  --set volume \
    icon="󰕾" \
    icon.color="${BLUE}" \
    width=34 \
    padding_left=4 \
    padding_right=4 \
    icon.padding_left=8 \
    icon.padding_right=8 \
    label.drawing=off \
    background.drawing=off \
    popup.align=right \
    popup.background.color=0x44111018 \
    popup.background.border_color=0x20f8ead2 \
    popup.background.border_width=1 \
    popup.background.corner_radius=14 \
    popup.background.shadow.drawing=on \
    popup.background.shadow.color=0x55111018 \
    popup.blur_radius=46 \
    script="${PLUGIN_DIR}/volume.sh" \
    click_script="\"${PLUGIN_DIR}/volume.sh\" toggle" \
  --subscribe volume volume_change system_woke

"$SKETCHYBAR_BIN" --add item volume.title popup.volume \
  --set volume.title \
    icon="󰕾" \
    icon.color="${BLUE}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Sound" \
    label.font="${FONT_TEXT}:Semibold:12.0" \
    label.color="${TEXT}" \
    label.padding_right=12 \
    width=210 \
    background.height=30 \
    background.corner_radius=10 \
    background.color=0x10f8ead2 \
    background.border_color=0x16f8ead2

for control in down mute up; do
  case "$control" in
    down) icon="󰝞"; label="Volume -10"; color="${BLUE}" ;;
    mute) icon="󰖁"; label="Mute"; color="${AMBER}" ;;
    up) icon="󰝝"; label="Volume +10"; color="${CYAN}" ;;
  esac

  "$SKETCHYBAR_BIN" --add item "volume.${control}" popup.volume \
    --set "volume.${control}" \
      icon="$icon" \
      icon.color="$color" \
      icon.padding_left=10 \
      icon.padding_right=8 \
      label="$label" \
      label.color="${TEXT}" \
      label.padding_right=12 \
      width=210 \
      background.height=28 \
      background.corner_radius=10 \
      background.color=0x08f8ead2 \
      background.border_color=0x0df8ead2 \
      click_script="\"${PLUGIN_DIR}/volume.sh\" ${control}"
done

"$SKETCHYBAR_BIN" --add item volume.output_header popup.volume \
  --set volume.output_header \
    icon="󰓃" \
    icon.color="${MUTED}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Output" \
    label.color="${MUTED}" \
    label.padding_right=12 \
    width=210 \
    background.height=24 \
    background.color=0x00000000 \
    background.border_color=0x00000000

for slot in 1 2 3 4; do
  "$SKETCHYBAR_BIN" --add item "volume.output.${slot}" popup.volume \
    --set "volume.output.${slot}" \
      drawing=off \
      icon="󰓃" \
      icon.color="${MUTED}" \
      icon.padding_left=10 \
      icon.padding_right=8 \
      label.color="${TEXT}" \
      label.padding_right=12 \
      width=210 \
      background.height=28 \
      background.corner_radius=10 \
      background.color=0x08f8ead2 \
      background.border_color=0x0df8ead2 \
      click_script="\"${PLUGIN_DIR}/volume.sh\" output-slot ${slot}"
done

"$SKETCHYBAR_BIN" --add item volume.input_header popup.volume \
  --set volume.input_header \
    icon="󰍬" \
    icon.color="${MUTED}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Input" \
    label.color="${MUTED}" \
    label.padding_right=12 \
    width=210 \
    background.height=24 \
    background.color=0x00000000 \
    background.border_color=0x00000000

for slot in 1 2 3; do
  "$SKETCHYBAR_BIN" --add item "volume.input.${slot}" popup.volume \
    --set "volume.input.${slot}" \
      drawing=off \
      icon="󰍬" \
      icon.color="${MUTED}" \
      icon.padding_left=10 \
      icon.padding_right=8 \
      label.color="${TEXT}" \
      label.padding_right=12 \
      width=210 \
      background.height=28 \
      background.corner_radius=10 \
      background.color=0x08f8ead2 \
      background.border_color=0x0df8ead2 \
      click_script="\"${PLUGIN_DIR}/volume.sh\" input-slot ${slot}"
done

"$SKETCHYBAR_BIN" --add item volume.settings popup.volume \
  --set volume.settings \
    icon="󰒓" \
    icon.color="${MUTED}" \
    icon.padding_left=10 \
    icon.padding_right=8 \
    label="Sound Settings" \
    label.color="${MUTED}" \
    label.padding_right=12 \
    width=210 \
    background.height=28 \
    background.corner_radius=10 \
    background.color=0x05f8ead2 \
    background.border_color=0x08f8ead2 \
    click_script="\"${PLUGIN_DIR}/volume.sh\" settings"

"$SKETCHYBAR_BIN" --add item cpu right \
  --set cpu \
    icon="󰍛" \
    icon.color="${ORANGE}" \
    width=52 \
    padding_left=4 \
    padding_right=4 \
    icon.padding_left=7 \
    icon.padding_right=4 \
    label.font="${FONT_MONO}:Medium:12.0" \
    label.color="${MUTED}" \
    background.drawing=off \
    script="${PLUGIN_DIR}/cpu.sh" \
    update_freq=8

"$SKETCHYBAR_BIN" --add item now_playing right \
  --set now_playing \
    drawing=off \
    updates=on \
    icon="󰐊" \
    icon.color="${ROSE}" \
    width=220 \
    label.max_chars=24 \
    padding_left=6 \
    padding_right=6 \
    background.color=0x14ff5f87 \
    background.border_color=0x32ff5f87 \
    script="${PLUGIN_DIR}/now_playing.sh" \
    update_freq=12 \
  --subscribe now_playing media_change system_woke

"$SKETCHYBAR_BIN" --add bracket system_status cpu volume bluetooth wifi battery power \
  --set system_status \
    background.color=0x04f8ead2 \
    background.corner_radius=14 \
    background.height=28 \
    background.border_width=1 \
    background.border_color=0x09f8ead2 \
    icon.drawing=off \
    label.drawing=off
