#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

[ -x "$YABAI_BIN" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/sketchybar"
visible_empty_file="$state_dir/visible-empty-space"
sender="${SENDER:-routine}"
spaces_json="$($YABAI_BIN -m query --spaces 2>/dev/null || printf '[]')"

mkdir -p "$state_dir"

focused_index="$(printf '%s' "$spaces_json" | jq -r '.[] | select(."has-focus" == true) | .index' 2>/dev/null | sed -n '1p')"
focused_windows="0"
if [ -n "$focused_index" ]; then
  focused_windows="$(printf '%s' "$spaces_json" | jq -r --argjson sid "$focused_index" '.[] | select(.index == $sid) | (.windows // [] | length)' 2>/dev/null | sed -n '1p')"
fi
case "$focused_windows" in (*[!0-9]*|'') focused_windows=0 ;; esac

case "$sender" in
  yabai_space_changed|yabai_spaces_changed)
    if [ -n "$focused_index" ] && [ "$focused_windows" -eq 0 ]; then
      printf '%s\n' "$focused_index" > "$visible_empty_file"
    else
      rm -f "$visible_empty_file"
    fi
    ;;
  yabai_window_changed)
    if [ -n "$focused_index" ] && [ "$focused_windows" -eq 0 ]; then
      rm -f "$visible_empty_file"
    fi
    ;;
esac

visible_empty="$(sed -n '1p' "$visible_empty_file" 2>/dev/null || true)"

for sid in 1 2 3 4 5 6 7 8 9 10; do
  label="$sid"
  [ "$sid" = "10" ] && label="0"

  space_json="$(printf '%s' "$spaces_json" | jq -c --argjson sid "$sid" '.[] | select(.index == $sid)' 2>/dev/null | sed -n '1p')"
  if [ -z "$space_json" ]; then
    "$SKETCHYBAR_BIN" --set "space.${sid}" drawing=off background.drawing=off
    continue
  fi

  focused="$(printf '%s' "$space_json" | jq -r '."has-focus" // false' 2>/dev/null || printf 'false')"
  windows="$(printf '%s' "$space_json" | jq -r '.windows // [] | length' 2>/dev/null || printf '0')"
  case "$windows" in (*[!0-9]*|'') windows=0 ;; esac

  if [ "$focused" = "true" ] && { [ "$windows" -gt 0 ] || [ "$visible_empty" = "$sid" ]; }; then
    "$SKETCHYBAR_BIN" --set "space.${sid}" \
      drawing=on \
      icon="$label" \
      icon.color="$CREAM" \
      background.color="$ITEM_BG_ACTIVE" \
      background.border_color="$ITEM_BORDER_ACTIVE" \
      background.shadow.color="$SHADOW" \
      background.shadow.drawing=off \
      background.drawing=on
  elif [ "$windows" -gt 0 ]; then
    "$SKETCHYBAR_BIN" --set "space.${sid}" \
      drawing=on \
      icon="$label" \
      icon.color="$AMBER" \
      background.color="$ITEM_BG_HOT" \
      background.border_color="$ITEM_BORDER" \
      background.shadow.drawing=off \
      background.drawing=on
  else
    "$SKETCHYBAR_BIN" --set "space.${sid}" \
      drawing=off \
      icon="$label" \
      icon.color="$MUTED" \
      background.color="$ITEM_BG" \
      background.border_color="$ITEM_BORDER" \
      background.shadow.drawing=off \
      background.drawing=off
  fi
done
