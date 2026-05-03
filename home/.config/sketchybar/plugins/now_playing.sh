#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

if ! command -v nowplaying-cli >/dev/null 2>&1; then
  "$SKETCHYBAR_BIN" --set "$NAME" drawing=off label="" label.drawing=off background.drawing=off
  exit 0
fi

clean_value() {
  case "$1" in
    ''|null|'(null)') printf '' ;;
    *) printf '%s' "$1" ;;
  esac
}

rate="$(clean_value "$(nowplaying-cli get playbackRate 2>/dev/null || true)")"
artist="$(clean_value "$(nowplaying-cli get artist 2>/dev/null || true)")"
title="$(clean_value "$(nowplaying-cli get title 2>/dev/null || true)")"

case "$rate" in
  ''|0|0.*)
    "$SKETCHYBAR_BIN" --set "$NAME" drawing=off label="" label.drawing=off background.drawing=off
    exit 0
    ;;
esac

if [ -z "$title" ]; then
  "$SKETCHYBAR_BIN" --set "$NAME" drawing=off label="" label.drawing=off background.drawing=off
  exit 0
fi

if [ -n "$artist" ]; then
  label="${artist} - ${title}"
else
  label="$title"
fi

"$SKETCHYBAR_BIN" --set "$NAME" drawing=on icon.color="$ROSE" label="$label" label.drawing=on background.drawing=on
