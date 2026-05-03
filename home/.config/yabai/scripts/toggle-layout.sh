#!/usr/bin/env sh
set -eu

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
[ -x "$YABAI_BIN" ] || YABAI_BIN="$(command -v yabai 2>/dev/null || printf '%s' /opt/homebrew/bin/yabai)"

layout="$($YABAI_BIN -m query --spaces --space 2>/dev/null | jq -r '.type // "bsp"' 2>/dev/null || printf 'bsp')"

case "$layout" in
  bsp) "$YABAI_BIN" -m space --layout stack ;;
  *) "$YABAI_BIN" -m space --layout bsp ;;
esac
