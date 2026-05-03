#!/usr/bin/env sh
# shellcheck disable=SC2153

# shellcheck source=home/.config/sketchybar/plugins/lib.sh
. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sketchybar"
OUTPUT_CACHE="$STATE_DIR/audio-outputs"
INPUT_CACHE="$STATE_DIR/audio-inputs"
ITEM_NAME="${NAME:-volume}"

current_volume() {
  osascript -e 'output volume of (get volume settings)' 2>/dev/null || printf '0'
}

current_muted() {
  osascript -e 'output muted of (get volume settings)' 2>/dev/null || printf 'false'
}

current_output() {
  SwitchAudioSource -t output -c 2>/dev/null || true
}

current_input() {
  SwitchAudioSource -t input -c 2>/dev/null || true
}

update_icon() {
  volume="${INFO:-$(current_volume)}"
  muted="$(current_muted)"
  case "$volume" in (*[!0-9]*|'') volume=0 ;; esac

  if [ "$muted" = "true" ] || [ "${volume:-0}" -eq 0 ]; then
    icon="󰖁"
    color="$MUTED"
    bg="off"
  elif [ "${volume:-0}" -lt 35 ]; then
    icon="󰕿"
    color="$BLUE"
    bg="off"
  elif [ "${volume:-0}" -lt 70 ]; then
    icon="󰖀"
    color="$BLUE"
    bg="off"
  else
    icon="󰕾"
    color="$CYAN"
    bg="off"
  fi

  "$SKETCHYBAR_BIN" --set "$ITEM_NAME" icon="$icon" icon.color="$color" label.drawing=off background.drawing="$bg"
}

hide_audio_slots() {
  for slot in 1 2 3 4; do
    "$SKETCHYBAR_BIN" --set "volume.output.${slot}" drawing=off
  done
  for slot in 1 2 3; do
    "$SKETCHYBAR_BIN" --set "volume.input.${slot}" drawing=off
  done
}

populate_outputs() {
  current="$(current_output)"
  SwitchAudioSource -t output -a 2>/dev/null | awk 'NF && !seen[$0]++' > "$OUTPUT_CACHE"

  slot=1
  while IFS= read -r device; do
    [ -n "$device" ] || continue
    [ "$slot" -le 4 ] || break

    if [ "$device" = "$current" ]; then
      icon="󰓃"
      color="$CYAN"
      background="$ITEM_BG_OK"
      border="$CYAN"
    else
      icon="󰓃"
      color="$MUTED"
      background=0x08f8ead2
      border=0x0df8ead2
    fi

    "$SKETCHYBAR_BIN" --set "volume.output.${slot}" \
      drawing=on \
      icon="$icon" \
      icon.color="$color" \
      label="$device" \
      label.max_chars=24 \
      background.color="$background" \
      background.border_color="$border"
    slot=$((slot + 1))
  done < "$OUTPUT_CACHE"

  if [ "$slot" -eq 1 ]; then
    "$SKETCHYBAR_BIN" --set volume.output.1 \
      drawing=on \
      icon="󰓃" \
      icon.color="$MUTED" \
      label="No output devices" \
      label.max_chars=24 \
      background.color=0x05f8ead2 \
      background.border_color=0x08f8ead2
    slot=2
  fi

  while [ "$slot" -le 4 ]; do
    "$SKETCHYBAR_BIN" --set "volume.output.${slot}" drawing=off
    slot=$((slot + 1))
  done
}

populate_inputs() {
  current="$(current_input)"
  SwitchAudioSource -t input -a 2>/dev/null | awk 'NF && !seen[$0]++' > "$INPUT_CACHE"

  slot=1
  while IFS= read -r device; do
    [ -n "$device" ] || continue
    [ "$slot" -le 3 ] || break

    if [ "$device" = "$current" ]; then
      icon="󰍬"
      color="$PURPLE"
      background="$ITEM_BG_OK"
      border="$PURPLE"
    else
      icon="󰍬"
      color="$MUTED"
      background=0x08f8ead2
      border=0x0df8ead2
    fi

    "$SKETCHYBAR_BIN" --set "volume.input.${slot}" \
      drawing=on \
      icon="$icon" \
      icon.color="$color" \
      label="$device" \
      label.max_chars=24 \
      background.color="$background" \
      background.border_color="$border"
    slot=$((slot + 1))
  done < "$INPUT_CACHE"

  if [ "$slot" -eq 1 ]; then
    "$SKETCHYBAR_BIN" --set volume.input.1 \
      drawing=on \
      icon="󰍬" \
      icon.color="$MUTED" \
      label="No input devices" \
      label.max_chars=24 \
      background.color=0x05f8ead2 \
      background.border_color=0x08f8ead2
    slot=2
  fi

  while [ "$slot" -le 3 ]; do
    "$SKETCHYBAR_BIN" --set "volume.input.${slot}" drawing=off
    slot=$((slot + 1))
  done
}

populate_popup() {
  mkdir -p "$STATE_DIR"

  volume="$(current_volume)"
  muted="$(current_muted)"
  case "$volume" in (*[!0-9]*|'') volume=0 ;; esac

  if [ "$muted" = "true" ] || [ "${volume:-0}" -eq 0 ]; then
    icon="󰖁"
    color="$MUTED"
  elif [ "${volume:-0}" -lt 35 ]; then
    icon="󰕿"
    color="$BLUE"
  elif [ "${volume:-0}" -lt 70 ]; then
    icon="󰖀"
    color="$BLUE"
  else
    icon="󰕾"
    color="$CYAN"
  fi

  if [ "$muted" = "true" ]; then
    title="Muted"
    mute_label="Unmute"
  else
    title="Volume ${volume}%"
    mute_label="Mute"
  fi

  output="$(current_output)"
  [ -n "$output" ] && title="$title - $output"

  "$SKETCHYBAR_BIN" --set volume.title icon="$icon" icon.color="$color" label="$title" label.max_chars=25 \
    --set volume.mute label="$mute_label" \
    --set volume.output_header drawing=on \
    --set volume.input_header drawing=on

  if command -v SwitchAudioSource >/dev/null 2>&1; then
    populate_outputs
    populate_inputs
  else
    hide_audio_slots
    "$SKETCHYBAR_BIN" --set volume.output_header drawing=off --set volume.input_header drawing=off
  fi
}

open_popup() {
  populate_popup
  "$SKETCHYBAR_BIN" --set volume popup.drawing=on
}

set_volume() {
  value="$1"
  case "$value" in (*[!0-9]*|'') value=0 ;; esac
  [ "$value" -lt 0 ] && value=0
  [ "$value" -gt 100 ] && value=100
  osascript -e "set volume output volume $value" -e 'set volume without output muted' >/dev/null 2>&1 || true
  update_icon
  open_popup
}

adjust_volume() {
  delta="$1"
  volume="$(current_volume)"
  case "$volume" in (*[!0-9]*|'') volume=0 ;; esac
  set_volume "$((volume + delta))"
}

toggle_mute() {
  if [ "$(current_muted)" = "true" ]; then
    osascript -e 'set volume without output muted' >/dev/null 2>&1 || true
  else
    osascript -e 'set volume with output muted' >/dev/null 2>&1 || true
  fi

  update_icon
  open_popup
}

switch_output_slot() {
  slot="$1"
  case "$slot" in (*[!0-9]*|'') exit 0 ;; esac
  device="$(sed -n "${slot}p" "$OUTPUT_CACHE" 2>/dev/null || true)"
  [ -n "$device" ] || exit 0
  SwitchAudioSource -t output -s "$device" >/dev/null 2>&1 || true
  update_icon
  open_popup
}

switch_input_slot() {
  slot="$1"
  case "$slot" in (*[!0-9]*|'') exit 0 ;; esac
  device="$(sed -n "${slot}p" "$INPUT_CACHE" 2>/dev/null || true)"
  [ -n "$device" ] || exit 0
  SwitchAudioSource -t input -s "$device" >/dev/null 2>&1 || true
  update_icon
  open_popup
}

case "${1:-update}" in
  toggle)
    populate_popup
    "$SKETCHYBAR_BIN" --set volume popup.drawing=toggle
    ;;
  open)
    open_popup
    ;;
  close)
    "$SKETCHYBAR_BIN" --set volume popup.drawing=off
    ;;
  down)
    adjust_volume -10
    ;;
  up)
    adjust_volume 10
    ;;
  mute)
    toggle_mute
    ;;
  output-slot)
    switch_output_slot "$2"
    ;;
  input-slot)
    switch_input_slot "$2"
    ;;
  settings)
    "$SKETCHYBAR_BIN" --set volume popup.drawing=off
    open x-apple.systempreferences:com.apple.Sound-Settings.extension >/dev/null 2>&1 || true
    ;;
  *)
    update_icon
    ;;
esac
