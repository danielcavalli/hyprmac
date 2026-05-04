#!/usr/bin/env sh

# shellcheck source=home/.config/sketchybar/plugins/lib.sh
. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sketchybar"
DEVICE_CACHE="$STATE_DIR/bluetooth-devices"
ITEM_NAME="${BLUETOOTH_ITEM:-bluetooth}"
TAB="$(printf '\t')"

has_blueutil() {
  command -v blueutil >/dev/null 2>&1
}

connected_count() {
  blueutil --connected --format json 2>/dev/null | jq -r 'length' 2>/dev/null || printf '0'
}

update_icon() {
  if ! has_blueutil; then
    "$SKETCHYBAR_BIN" --set "$ITEM_NAME" icon="󰂲" icon.color="$MUTED" label.drawing=off background.drawing=off
    return
  fi

  power="$(blueutil --power 2>/dev/null || true)"

  if [ "$power" != "1" ]; then
    "$SKETCHYBAR_BIN" --set "$ITEM_NAME" icon="󰂲" icon.color="$MUTED" label.drawing=off background.drawing=off
    return
  fi

  connected="$(connected_count)"
  case "$connected" in (*[!0-9]*|'') connected=0 ;; esac

  if [ "${connected:-0}" -gt 0 ]; then
    "$SKETCHYBAR_BIN" --set "$ITEM_NAME" icon="󰂱" icon.color="$CYAN" label.drawing=off background.drawing=off
  else
    "$SKETCHYBAR_BIN" --set "$ITEM_NAME" icon="󰂯" icon.color="$BLUE" label.drawing=off background.drawing=off
  fi
}

hide_device_slots() {
  for slot in 1 2 3 4 5; do
    "$SKETCHYBAR_BIN" --set "bluetooth.device.${slot}" drawing=off
  done
}

populate_popup() {
  mkdir -p "$STATE_DIR"

  if ! has_blueutil; then
    : > "$DEVICE_CACHE"
    "$SKETCHYBAR_BIN" --set bluetooth.title icon="󰂲" icon.color="$MUTED" label="Bluetooth unavailable" \
      --set bluetooth.toggle drawing=off
    hide_device_slots
    return
  fi

  power="$(blueutil --power 2>/dev/null || true)"
  if [ "$power" != "1" ]; then
    : > "$DEVICE_CACHE"
    "$SKETCHYBAR_BIN" --set bluetooth.title icon="󰂲" icon.color="$MUTED" label="Bluetooth Off" \
      --set bluetooth.toggle drawing=on icon="󰔡" icon.color="$LIME" label="Turn Bluetooth On"
    hide_device_slots
    return
  fi

  connected="$(connected_count)"
  case "$connected" in (*[!0-9]*|'') connected=0 ;; esac

  if [ "$connected" -gt 0 ]; then
    title="$connected connected"
    title_icon="󰂱"
    title_color="$CYAN"
  else
    title="No devices connected"
    title_icon="󰂯"
    title_color="$BLUE"
  fi

  "$SKETCHYBAR_BIN" --set bluetooth.title icon="$title_icon" icon.color="$title_color" label="$title" \
    --set bluetooth.toggle drawing=on icon="󰔡" icon.color="$ORANGE" label="Turn Bluetooth Off"

  blueutil --paired --format json 2>/dev/null \
    | jq -r '.[] | [.address, .name, (.connected | tostring)] | @tsv' 2>/dev/null \
    > "$DEVICE_CACHE"

  slot=1
  while IFS="$TAB" read -r address name connected_state; do
    [ -n "$address" ] || continue
    [ "$slot" -le 5 ] || break

    if [ "$connected_state" = "true" ]; then
      icon="󰂱"
      color="$CYAN"
      label="$name"
      background="$ITEM_BG_OK"
      border="$ITEM_BORDER_OK"
    else
      icon="󰂯"
      color="$MUTED"
      label="$name"
      background="$POPUP_ITEM_BG"
      border="$POPUP_ITEM_BORDER"
    fi

    "$SKETCHYBAR_BIN" --set "bluetooth.device.${slot}" \
      drawing=on \
      icon="$icon" \
      icon.color="$color" \
      label="$label" \
      label.max_chars=24 \
      background.color="$background" \
      background.border_color="$border"
    slot=$((slot + 1))
  done < "$DEVICE_CACHE"

  if [ "$slot" -eq 1 ]; then
    "$SKETCHYBAR_BIN" --set bluetooth.device.1 \
      drawing=on \
      icon="󰂯" \
      icon.color="$MUTED" \
      label="No paired devices" \
      label.max_chars=24 \
      background.color="$POPUP_MUTED_BG" \
      background.border_color="$POPUP_MUTED_BORDER"
    slot=2
  fi

  while [ "$slot" -le 5 ]; do
    "$SKETCHYBAR_BIN" --set "bluetooth.device.${slot}" drawing=off
    slot=$((slot + 1))
  done
}

open_popup() {
  populate_popup
  "$SKETCHYBAR_BIN" --set bluetooth popup.drawing=on
}

device_slot() {
  slot="$1"
  case "$slot" in (*[!0-9]*|'') exit 0 ;; esac

  line="$(sed -n "${slot}p" "$DEVICE_CACHE" 2>/dev/null || true)"
  [ -n "$line" ] || exit 0

  address="${line%%"${TAB}"*}"
  rest="${line#*"${TAB}"}"
  name="${rest%%"${TAB}"*}"
  connected_state="${rest##*"${TAB}"}"
  [ -n "$address" ] || exit 0

  if [ "$(blueutil --power 2>/dev/null || true)" != "1" ]; then
    blueutil --power on >/dev/null 2>&1 || true
  fi

  if [ "$connected_state" = "true" ]; then
    "$SKETCHYBAR_BIN" --set bluetooth.title icon="󰂲" icon.color="$AMBER" label="Disconnecting $name"
    blueutil --disconnect "$address" >/dev/null 2>&1 || true
  else
    "$SKETCHYBAR_BIN" --set bluetooth.title icon="󰂯" icon.color="$AMBER" label="Connecting $name"
    blueutil --connect "$address" >/dev/null 2>&1 || true
  fi

  update_icon
  open_popup
}

power_toggle() {
  has_blueutil || exit 0
  blueutil --power toggle >/dev/null 2>&1 || true
  update_icon
  open_popup
}

case "${1:-update}" in
  toggle)
    populate_popup
    "$SKETCHYBAR_BIN" --set bluetooth popup.drawing=toggle
    ;;
  open)
    open_popup
    ;;
  close)
    "$SKETCHYBAR_BIN" --set bluetooth popup.drawing=off
    ;;
  refresh)
    open_popup
    ;;
  device-slot)
    device_slot "$2"
    ;;
  power-toggle)
    power_toggle
    ;;
  settings)
    "$SKETCHYBAR_BIN" --set bluetooth popup.drawing=off
    open x-apple.systempreferences:com.apple.BluetoothSettings >/dev/null 2>&1 || true
    ;;
  *)
    update_icon
    ;;
esac
