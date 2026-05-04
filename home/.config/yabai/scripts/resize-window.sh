#!/usr/bin/env sh
set -eu

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
[ -x "$YABAI_BIN" ] || YABAI_BIN="$(command -v yabai 2>/dev/null || printf '%s' /opt/homebrew/bin/yabai)"

axis="${1:-}"
direction="${2:-}"
amount="${3:-40}"

command -v jq >/dev/null 2>&1 || exit 1

case "$amount" in (*[!0-9]*|'') amount=40 ;; esac

case "$axis:$direction" in
  width:shrink) dimension="w" ;;
  width:grow) dimension="w" ;;
  height:shrink) dimension="h" ;;
  height:grow) dimension="h" ;;
  *) exit 2 ;;
esac

frame_dimension() {
  "$YABAI_BIN" -m query --windows --window 2>/dev/null \
    | jq -r --arg dimension "$dimension" '.frame[$dimension] | round' 2>/dev/null
}

changed_as_requested() {
  before="$1"
  after="$2"

  case "$direction" in
    grow) [ "$after" -gt "$before" ] ;;
    shrink) [ "$after" -lt "$before" ] ;;
  esac
}

try_resize() {
  edge="$1"
  dx="$2"
  dy="$3"
  undo_dx="$4"
  undo_dy="$5"

  before="$(frame_dimension)"
  case "$before" in (*[!0-9]*|'') return 1 ;; esac

  "$YABAI_BIN" -m window --resize "${edge}:${dx}:${dy}" >/dev/null 2>&1 || return 1

  after="$(frame_dimension)"
  case "$after" in (*[!0-9]*|'') return 1 ;; esac

  if changed_as_requested "$before" "$after"; then
    exit 0
  fi

  if [ "$after" -ne "$before" ]; then
    "$YABAI_BIN" -m window --resize "${edge}:${undo_dx}:${undo_dy}" >/dev/null 2>&1 || true
  fi

  return 1
}

case "$axis:$direction" in
  width:shrink)
    try_resize right "-$amount" 0 "$amount" 0 || try_resize left "$amount" 0 "-$amount" 0 || true
    ;;
  width:grow)
    try_resize right "$amount" 0 "-$amount" 0 || try_resize left "-$amount" 0 "$amount" 0 || true
    ;;
  height:shrink)
    try_resize bottom 0 "-$amount" 0 "$amount" || try_resize top 0 "$amount" 0 "-$amount" || true
    ;;
  height:grow)
    try_resize bottom 0 "$amount" 0 "-$amount" || try_resize top 0 "-$amount" 0 "$amount" || true
    ;;
esac
