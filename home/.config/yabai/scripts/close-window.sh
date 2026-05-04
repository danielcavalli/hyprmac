#!/usr/bin/env sh
set -eu

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
[ -x "$YABAI_BIN" ] || YABAI_BIN="$(command -v yabai 2>/dev/null || printf '%s' /opt/homebrew/bin/yabai)"
BORDERS_BIN="${BORDERS_BIN:-/opt/homebrew/bin/borders}"
[ -x "$BORDERS_BIN" ] || BORDERS_BIN="$(command -v borders 2>/dev/null || printf '%s' /opt/homebrew/bin/borders)"
BORDERS_RC="${BORDERS_RC:-$HOME/.config/borders/bordersrc}"

dry_run=0
[ "${1:-}" = "--dry-run" ] && dry_run=1

command -v jq >/dev/null 2>&1 || exit 1

window_json="$($YABAI_BIN -m query --windows --window 2>/dev/null || true)"
[ -n "$window_json" ] || exit 0

window_id="$(printf '%s' "$window_json" | jq -r '.id')"
pid="$(printf '%s' "$window_json" | jq -r '.pid')"
app="$(printf '%s' "$window_json" | jq -r '.app')"

window_exists() {
  "$YABAI_BIN" -m query --windows 2>/dev/null | jq -e --argjson id "$window_id" 'any(.[]; .id == $id)' >/dev/null 2>&1
}

borders_muted=0

mute_borders() {
  [ "${HYPRMAC_CLOSE_MUTE_BORDERS:-1}" = "1" ] || return 0
  [ -x "$BORDERS_BIN" ] || return 0

  "$BORDERS_BIN" width=0.0 active_color=0x00ffb454 inactive_color=0x00ffead2 background_color=0x00000000 >/dev/null 2>&1 || true
  borders_muted=1
}

restore_borders() {
  [ "$borders_muted" -eq 1 ] || return 0
  borders_muted=0

  (
    sleep 0.05
    if [ -x "$BORDERS_RC" ]; then
      "$BORDERS_RC"
    elif [ -r "$BORDERS_RC" ]; then
      /usr/bin/env bash "$BORDERS_RC"
    elif [ -x "$BORDERS_BIN" ]; then
      "$BORDERS_BIN" style=round width=6.0 hidpi=on ax_focus=on active_color=0xffffb454 inactive_color=0x44ffead2
    fi
  ) >/dev/null 2>&1 &
}

wait_until_closed() {
  attempts="$1"
  while [ "$attempts" -gt 0 ]; do
    sleep 0.03
    window_exists || return 0
    attempts=$((attempts - 1))
  done

  return 1
}

pid_window_count() {
  "$YABAI_BIN" -m query --windows 2>/dev/null | jq -r --argjson pid "$pid" '[.[] | select(.pid == $pid)] | length' 2>/dev/null || printf '0'
}

terminate_pid_if_last_window() {
  count="$(pid_window_count)"
  case "$count" in (*[!0-9]*|'') count=0 ;; esac
  [ "$count" -eq 0 ] || return 0

  case "$app" in
    Finder|Dock|SystemUIServer|ControlCenter|NotificationCenter) return 0 ;;
  esac

  kill -TERM "$pid" >/dev/null 2>&1 || true
  sleep 0.35

  if kill -0 "$pid" >/dev/null 2>&1 && [ "$(pid_window_count)" = "0" ]; then
    kill -KILL "$pid" >/dev/null 2>&1 || true
  fi
}

finish_closed() {
  restore_borders
  trap - EXIT
  terminate_pid_if_last_window
  exit 0
}

if [ "$dry_run" -eq 1 ]; then
  printf 'target: id=%s pid=%s app=%s windows_for_pid=%s\n' "$window_id" "$pid" "$app" "$(pid_window_count)"
  exit 0
fi

trap 'restore_borders' EXIT
mute_borders

osascript -e 'tell application "System Events" to keystroke "w" using command down' >/dev/null 2>&1 || true
wait_until_closed 4 || true
if ! window_exists; then
  finish_closed
fi

"$YABAI_BIN" -m window --close >/dev/null 2>&1 || true
wait_until_closed 4 || true
if ! window_exists; then
  finish_closed
fi

osascript <<APPLESCRIPT >/dev/null 2>&1 || true
tell application "System Events"
  set targetProcess to first process whose unix id is $pid
  if exists window 1 of targetProcess then
    if exists button 1 of window 1 of targetProcess then click button 1 of window 1 of targetProcess
  end if
end tell
APPLESCRIPT
wait_until_closed 4 || true
if ! window_exists; then
  finish_closed
fi

restore_borders
trap - EXIT
terminate_pid_if_last_window
