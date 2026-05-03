#!/usr/bin/env sh
set -eu

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
[ -x "$YABAI_BIN" ] || YABAI_BIN="$(command -v yabai 2>/dev/null || printf '%s' /opt/homebrew/bin/yabai)"

window_json="$("$YABAI_BIN" -m query --windows --window 2>/dev/null || true)"
[ -n "$window_json" ] || exit 0
[ -x "$(command -v jq 2>/dev/null || true)" ] || exit 0

is_floating="$(printf '%s' "$window_json" | jq -r '."is-floating"')"

if [ "$is_floating" != "true" ]; then
  "$YABAI_BIN" -m window --toggle float
fi

"$YABAI_BIN" -m window --grid 10:10:1:1:8:8
