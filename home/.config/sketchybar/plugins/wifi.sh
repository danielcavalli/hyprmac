#!/usr/bin/env sh

# shellcheck source=home/.config/sketchybar/plugins/lib.sh
. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sketchybar"
NETWORK_CACHE="$STATE_DIR/wifi-networks"
ITEM_NAME="${NAME:-wifi}"

wifi_device() {
  networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi|AirPort/{getline; print $2; exit}'
}

wifi_power() {
  networksetup -getairportpower "$1" 2>/dev/null | awk '{print $NF}'
}

current_ssid() {
  device="$1"
  ssid="$(networksetup -getairportnetwork "$device" 2>/dev/null | sed 's/^Current Wi-Fi Network: //')"
  if [ "$ssid" = "You are not associated with an AirPort network." ]; then
    ssid=""
  fi

  if [ -z "$ssid" ]; then
    ipconfig getsummary "$device" 2>/dev/null | awk -F ' : ' '/ SSID/{print $2; exit}'
  else
    printf '%s\n' "$ssid"
  fi
}

link_active() {
  ipconfig getsummary "$1" 2>/dev/null | awk -F ' : ' '/LinkStatusActive/{print $2; exit}'
}

saved_networks() {
  networksetup -listpreferredwirelessnetworks "$1" 2>/dev/null \
    | sed '1d; s/^[[:space:]]*//' \
    | awk 'NF && !seen[$0]++'
}

update_icon() {
  device="$(wifi_device)"
  ssid=""
  power=""
  active=""

  if [ -n "$device" ]; then
    power="$(wifi_power "$device")"
    ssid="$(current_ssid "$device")"
    active="$(link_active "$device")"
  fi

  if [ -z "$device" ] || [ "$power" = "Off" ]; then
    "$SKETCHYBAR_BIN" --set "$ITEM_NAME" icon="󰤭" icon.color="$MUTED" label.drawing=off background.drawing=off
  elif [ -z "$ssid" ] && [ "$active" != "TRUE" ]; then
    "$SKETCHYBAR_BIN" --set "$ITEM_NAME" icon="󰤮" icon.color="$MUTED" label.drawing=off background.drawing=off
  else
    "$SKETCHYBAR_BIN" --set "$ITEM_NAME" icon="󰤨" icon.color="$LIME" label.drawing=off background.drawing=off
  fi
}

hide_network_slots() {
  for slot in 1 2 3 4 5 6; do
    "$SKETCHYBAR_BIN" --set "wifi.network.${slot}" drawing=off
  done
}

populate_popup() {
  mkdir -p "$STATE_DIR"

  device="$(wifi_device)"
  if [ -z "$device" ]; then
    : > "$NETWORK_CACHE"
    "$SKETCHYBAR_BIN" --set wifi.title icon="󰤭" icon.color="$MUTED" label="Wi-Fi unavailable" \
      --set wifi.toggle drawing=off \
      --set wifi.refresh drawing=off
    hide_network_slots
    return
  fi

  power="$(wifi_power "$device")"
  ssid="$(current_ssid "$device")"

  if [ "$power" = "Off" ]; then
    : > "$NETWORK_CACHE"
    "$SKETCHYBAR_BIN" --set wifi.title icon="󰤭" icon.color="$MUTED" label="Wi-Fi Off" \
      --set wifi.toggle drawing=on icon="󰔡" icon.color="$LIME" label="Turn Wi-Fi On" \
      --set wifi.refresh drawing=off
    hide_network_slots
    return
  fi

  if [ -n "$ssid" ]; then
    title="$ssid"
    title_icon="󰤨"
    title_color="$LIME"
  else
    title="Not Connected"
    title_icon="󰤮"
    title_color="$MUTED"
  fi

  "$SKETCHYBAR_BIN" --set wifi.title icon="$title_icon" icon.color="$title_color" label="$title" \
    --set wifi.toggle drawing=on icon="󰔡" icon.color="$ROSE" label="Turn Wi-Fi Off" \
    --set wifi.refresh drawing=on

  networks="$(saved_networks "$device")"
  printf '%s\n' "$networks" | awk 'NF' > "$NETWORK_CACHE"

  slot=1
  while IFS= read -r network; do
    [ -n "$network" ] || continue
    [ "$slot" -le 6 ] || break

    if [ "$network" = "$ssid" ]; then
      icon="󰤨"
      color="$LIME"
      background="$ITEM_BG_OK"
      border="$CYAN"
    else
      icon="󰤯"
      color="$MUTED"
      background=0x08f8ead2
      border=0x0df8ead2
    fi

    "$SKETCHYBAR_BIN" --set "wifi.network.${slot}" \
      drawing=on \
      icon="$icon" \
      icon.color="$color" \
      label="$network" \
      label.max_chars=24 \
      background.color="$background" \
      background.border_color="$border"
    slot=$((slot + 1))
  done <<EOF
$networks
EOF

  if [ "$slot" -eq 1 ]; then
    "$SKETCHYBAR_BIN" --set wifi.network.1 \
      drawing=on \
      icon="󰤮" \
      icon.color="$MUTED" \
      label="No saved networks" \
      label.max_chars=24 \
      background.color=0x05f8ead2 \
      background.border_color=0x08f8ead2
    slot=2
  fi

  while [ "$slot" -le 6 ]; do
    "$SKETCHYBAR_BIN" --set "wifi.network.${slot}" drawing=off
    slot=$((slot + 1))
  done
}

open_popup() {
  populate_popup
  "$SKETCHYBAR_BIN" --set wifi popup.drawing=on
}

connect_slot() {
  slot="$1"
  case "$slot" in (*[!0-9]*|'') exit 0 ;; esac

  device="$(wifi_device)"
  [ -n "$device" ] || exit 0

  ssid="$(sed -n "${slot}p" "$NETWORK_CACHE" 2>/dev/null || true)"
  [ -n "$ssid" ] || exit 0

  if [ "$(wifi_power "$device")" = "Off" ]; then
    networksetup -setairportpower "$device" on >/dev/null 2>&1 || true
  fi

  "$SKETCHYBAR_BIN" --set wifi.title icon="󰑐" icon.color="$AMBER" label="Joining $ssid"

  if networksetup -setairportnetwork "$device" "$ssid" >/dev/null 2>&1; then
    update_icon
    open_popup
  else
    "$SKETCHYBAR_BIN" --set wifi.title icon="󰤮" icon.color="$ROSE" label="Could not join $ssid"
  fi
}

power_toggle() {
  device="$(wifi_device)"
  [ -n "$device" ] || exit 0

  if [ "$(wifi_power "$device")" = "Off" ]; then
    networksetup -setairportpower "$device" on >/dev/null 2>&1 || true
  else
    networksetup -setairportpower "$device" off >/dev/null 2>&1 || true
  fi

  update_icon
  open_popup
}

case "${1:-update}" in
  toggle)
    populate_popup
    "$SKETCHYBAR_BIN" --set wifi popup.drawing=toggle
    ;;
  open)
    open_popup
    ;;
  close)
    "$SKETCHYBAR_BIN" --set wifi popup.drawing=off
    ;;
  refresh)
    open_popup
    ;;
  connect-slot)
    connect_slot "$2"
    ;;
  power-toggle)
    power_toggle
    ;;
  settings)
    "$SKETCHYBAR_BIN" --set wifi popup.drawing=off
    open x-apple.systempreferences:com.apple.WiFi-Settings.extension >/dev/null 2>&1 || true
    ;;
  *)
    update_icon
    ;;
esac
