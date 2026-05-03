#!/usr/bin/env sh
set -eu

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
[ -x "$YABAI_BIN" ] || YABAI_BIN="$(command -v yabai 2>/dev/null || printf '%s' /opt/homebrew/bin/yabai)"

target="${1:-10}"
current="$("$YABAI_BIN" -m query --spaces | jq 'length')"

while [ "$current" -lt "$target" ]; do
  "$YABAI_BIN" -m space --create || break
  current=$((current + 1))
done

space=1
while [ "$space" -le "$target" ]; do
  "$YABAI_BIN" -m space "$space" --label "ws$space" >/dev/null 2>&1 || true
  space=$((space + 1))
done
