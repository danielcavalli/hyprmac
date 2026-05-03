#!/usr/bin/env sh
set -eu

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
[ -x "$YABAI_BIN" ] || YABAI_BIN="$(command -v yabai 2>/dev/null || printf '%s' /opt/homebrew/bin/yabai)"

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

if [ "$dry_run" -eq 1 ]; then
  printf 'target: id=%s pid=%s app=%s windows_for_pid=%s\n' "$window_id" "$pid" "$app" "$(pid_window_count)"
  exit 0
fi

"$YABAI_BIN" -m window --close >/dev/null 2>&1 || true
sleep 0.18
if ! window_exists; then
  terminate_pid_if_last_window
  exit 0
fi

osascript -e 'tell application "System Events" to keystroke "w" using command down' >/dev/null 2>&1 || true
sleep 0.20
if ! window_exists; then
  terminate_pid_if_last_window
  exit 0
fi

osascript <<APPLESCRIPT >/dev/null 2>&1 || true
tell application "System Events"
  set targetProcess to first process whose unix id is $pid
  if exists window 1 of targetProcess then
    if exists button 1 of window 1 of targetProcess then click button 1 of window 1 of targetProcess
  end if
end tell
APPLESCRIPT
sleep 0.20
if ! window_exists; then
  terminate_pid_if_last_window
  exit 0
fi

terminate_pid_if_last_window
