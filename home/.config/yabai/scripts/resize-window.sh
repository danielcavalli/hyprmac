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

focused_window_info() {
  "$YABAI_BIN" -m query --windows --window 2>/dev/null \
    | jq -r '[.frame.x, .frame.y, .frame.w, .frame.h, ."is-floating"] | map(if type == "number" then (round | tostring) else tostring end) | join(" ")' 2>/dev/null
}

space_bounds_info() {
  "$YABAI_BIN" -m query --windows --space 2>/dev/null \
    | jq -r '
      map(select(."is-floating" == false and ."is-minimized" == false and ."is-hidden" == false)) as $wins
      | if ($wins | length) < 2 then empty else
          [
            ($wins | map(.frame.x) | min | round),
            ($wins | map(.frame.x + .frame.w) | max | round),
            ($wins | map(.frame.y) | min | round),
            ($wins | map(.frame.y + .frame.h) | max | round),
            ($wins | length)
          ] | map(tostring) | join(" ")
        end
    ' 2>/dev/null
}

changed_as_requested() {
  before="$1"
  after="$2"

  case "$direction" in
    grow) [ "$after" -gt "$before" ] ;;
    shrink) [ "$after" -lt "$before" ] ;;
  esac
}

wait_for_dimension_change() {
  before="$1"
  attempts=6

  while [ "$attempts" -gt 0 ]; do
    sleep 0.03
    after="$(frame_dimension)"
    case "$after" in (*[!0-9]*|'') return 1 ;; esac
    [ "$after" -ne "$before" ] && return 0
    attempts=$((attempts - 1))
  done

  return 1
}

try_resize_no_bounce() {
  edge="$1"
  dx="$2"
  dy="$3"

  before="$(frame_dimension)"
  case "$before" in (*[!0-9]*|'') return 1 ;; esac

  "$YABAI_BIN" -m window --resize "${edge}:${dx}:${dy}" >/dev/null 2>&1 || return 1

  if ! wait_for_dimension_change "$before"; then
    return 1
  fi

  changed_as_requested "$before" "$after"
}

resize_from_frame_position() {
  tolerance=2

  focused_info="$(focused_window_info)" || return 1
  IFS=' ' read -r x y w h is_floating <<EOF
$focused_info
EOF

  case "$x$y$w$h" in (*[!0123456789-]*|'') return 1 ;; esac

  if [ "$is_floating" = "true" ]; then
    case "$axis:$direction" in
      width:shrink) try_resize_no_bounce right "-$amount" 0 ;;
      width:grow) try_resize_no_bounce right "$amount" 0 ;;
      height:shrink) try_resize_no_bounce bottom 0 "-$amount" ;;
      height:grow) try_resize_no_bounce bottom 0 "$amount" ;;
    esac
    return
  fi

  bounds_info="$(space_bounds_info)" || return 1
  [ -n "$bounds_info" ] || return 0
  IFS=' ' read -r min_x max_right min_y max_bottom window_count <<EOF
$bounds_info
EOF

  case "$min_x$max_right$min_y$max_bottom$window_count" in (*[!0123456789-]*|'') return 1 ;; esac
  [ "$window_count" -gt 1 ] || return 0

  right=$((x + w))
  bottom=$((y + h))

  case "$axis:$direction" in
    width:shrink)
      if [ $((max_right - right)) -gt "$tolerance" ]; then
        try_resize_no_bounce right "-$amount" 0
      elif [ $((x - min_x)) -gt "$tolerance" ]; then
        try_resize_no_bounce left "$amount" 0
      fi
      ;;
    width:grow)
      if [ $((max_right - right)) -gt "$tolerance" ]; then
        try_resize_no_bounce right "$amount" 0
      elif [ $((x - min_x)) -gt "$tolerance" ]; then
        try_resize_no_bounce left "-$amount" 0
      fi
      ;;
    height:shrink)
      if [ $((max_bottom - bottom)) -gt "$tolerance" ]; then
        try_resize_no_bounce bottom 0 "-$amount"
      elif [ $((y - min_y)) -gt "$tolerance" ]; then
        try_resize_no_bounce top 0 "$amount"
      fi
      ;;
    height:grow)
      if [ $((max_bottom - bottom)) -gt "$tolerance" ]; then
        try_resize_no_bounce bottom 0 "$amount"
      elif [ $((y - min_y)) -gt "$tolerance" ]; then
        try_resize_no_bounce top 0 "-$amount"
      fi
      ;;
  esac
}

resize_from_frame_position || true
