#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

HYPRMAC_BIN="${HYPRMAC_BIN:-$HOME/.local/bin/hyprmac}"
POWER_SCRIPT="${PLUGIN_DIR:-$HOME/.config/sketchybar/plugins}/power.sh"

set_item() {
  "$SKETCHYBAR_BIN" --set "$@"
}

reset_menu() {
  set_item power.lock \
    drawing=on \
    icon="󰌾" \
    icon.color="$BLUE" \
    label="Lock" \
    label.color="$TEXT" \
    background.color="$POPUP_ITEM_BG" \
    background.border_color="$POPUP_ITEM_BORDER" \
    click_script="\"${POWER_SCRIPT}\" lock"

  set_item power.sleep \
    drawing=on \
    icon="󰒲" \
    icon.color="$BLUE" \
    label="Sleep" \
    label.color="$TEXT" \
    background.color="$POPUP_ITEM_BG" \
    background.border_color="$POPUP_ITEM_BORDER" \
    click_script="\"${POWER_SCRIPT}\" sleep"

  set_item power.restart \
    drawing=on \
    icon="󰑐" \
    icon.color="$AMBER" \
    label="Restart" \
    label.color="$TEXT" \
    background.color="$POPUP_ITEM_BG" \
    background.border_color="$POPUP_ITEM_BORDER" \
    click_script="\"${POWER_SCRIPT}\" confirm-restart"

  set_item power.shutdown \
    drawing=on \
    icon="󰐥" \
    icon.color="$ROSE" \
    label="Shut Down" \
    label.color="$TEXT" \
    background.color="$POPUP_ITEM_BG" \
    background.border_color="$POPUP_ITEM_BORDER" \
    click_script="\"${POWER_SCRIPT}\" confirm-shutdown"
}

confirm_restart() {
  set_item power.lock \
    drawing=on \
    icon="󰜺" \
    icon.color="$MUTED" \
    label="Cancel" \
    background.color="$POPUP_ITEM_BG" \
    background.border_color="$POPUP_ITEM_BORDER" \
    click_script="\"${POWER_SCRIPT}\" cancel"

  set_item power.sleep drawing=off

  set_item power.restart \
    drawing=on \
    icon="󰑐" \
    icon.color="$AMBER" \
    label="Restart Now" \
    background.color="$ITEM_BG_CONFIRM" \
    background.border_color="$ITEM_BORDER_CONFIRM" \
    click_script="\"${POWER_SCRIPT}\" restart-now"

  set_item power.shutdown drawing=off
}

confirm_shutdown() {
  set_item power.lock \
    drawing=on \
    icon="󰜺" \
    icon.color="$MUTED" \
    label="Cancel" \
    background.color="$POPUP_ITEM_BG" \
    background.border_color="$POPUP_ITEM_BORDER" \
    click_script="\"${POWER_SCRIPT}\" cancel"

  set_item power.sleep drawing=off
  set_item power.restart drawing=off

  set_item power.shutdown \
    drawing=on \
    icon="󰐥" \
    icon.color="$ROSE" \
    label="Shut Down Now" \
    background.color="$ITEM_BG_WARN" \
    background.border_color="$ITEM_BORDER_WARN" \
    click_script="\"${POWER_SCRIPT}\" shutdown-now"
}

hide_popup() {
  set_item power popup.drawing=off
}

case "${1:-toggle}" in
  toggle)
    reset_menu
    set_item power popup.drawing=toggle
    ;;
  open)
    reset_menu
    set_item power popup.drawing=on
    ;;
  close|cancel)
    reset_menu
    hide_popup
    ;;
  lock)
    hide_popup
    "$HYPRMAC_BIN" power lock
    ;;
  sleep)
    hide_popup
    "$HYPRMAC_BIN" power sleep
    ;;
  confirm-restart)
    confirm_restart
    ;;
  confirm-shutdown)
    confirm_shutdown
    ;;
  restart-now)
    hide_popup
    "$HYPRMAC_BIN" power restart-now
    ;;
  shutdown-now)
    hide_popup
    "$HYPRMAC_BIN" power shutdown-now
    ;;
esac
