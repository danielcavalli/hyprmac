#!/usr/bin/env sh
set -eu

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
[ -x "$YABAI_BIN" ] || YABAI_BIN="$(command -v yabai 2>/dev/null || printf '%s' /opt/homebrew/bin/yabai)"

"$YABAI_BIN" -m window --toggle float
"$YABAI_BIN" -m window --toggle sticky >/dev/null 2>&1 || true
"$YABAI_BIN" -m window --sub-layer above >/dev/null 2>&1 || true
