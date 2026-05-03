#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

sid="$1"

if [ ! -x "$YABAI_BIN" ] || ! command -v jq >/dev/null 2>&1; then
  "$SKETCHYBAR_BIN" --set "$NAME" icon="$sid" label.drawing=off
  exit 0
fi

space_json="$("$YABAI_BIN" -m query --spaces --space "$sid" 2>/dev/null || true)"
if [ -z "$space_json" ]; then
  "$SKETCHYBAR_BIN" --set "$NAME" drawing=off
  exit 0
fi

focused="$(printf '%s' "$space_json" | jq -r '."has-focus" // false' 2>/dev/null || printf 'false')"
windows="$(printf '%s' "$space_json" | jq -r '.windows // [] | length' 2>/dev/null || printf '0')"
label="$sid"
[ "$sid" = "10" ] && label="0"

if [ "$focused" = "true" ]; then
  "$SKETCHYBAR_BIN" --set "$NAME" \
    drawing=on \
    icon="$label" \
    icon.color="$CREAM" \
    background.drawing=on \
    background.color="$ITEM_BG_ACTIVE" \
    background.border_color="$ITEM_BORDER_ACTIVE" \
    background.shadow.color="$SHADOW" \
    background.shadow.drawing=off
elif [ "${windows:-0}" -gt 0 ]; then
  "$SKETCHYBAR_BIN" --set "$NAME" \
    drawing=on \
    icon="$label" \
    icon.color="$AMBER" \
    background.drawing=on \
    background.color="$ITEM_BG_HOT" \
    background.border_color="$ITEM_BORDER" \
    background.shadow.drawing=off
else
  "$SKETCHYBAR_BIN" --set "$NAME" \
    drawing=off \
    icon="$label" \
    icon.color="$MUTED" \
    background.color="$ITEM_BG" \
    background.border_color="$ITEM_BORDER" \
    background.shadow.drawing=off \
    background.drawing=off
fi
