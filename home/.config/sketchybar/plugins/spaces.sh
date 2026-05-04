#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

[ -x "$YABAI_BIN" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/sketchybar"
visible_empty_file="$state_dir/visible-empty-space"
spacer_state_file="$state_dir/space-spacer-state"
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
previous_visible=""
visible_spaces=""
gap_after_spaces=""
any_visible=0

for sid in 1 2 3 4 5 6 7 8 9 10; do
  label="$sid"
  [ "$sid" = "10" ] && label="0"
  is_visible=0

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
      icon.color="$SPACE_ACTIVE_ICON" \
      background.color="$SPACE_ACTIVE_BG" \
      background.border_color="$SPACE_ACTIVE_BORDER" \
      background.shadow.color="$SHADOW" \
      background.shadow.drawing=on \
      background.drawing=on
    is_visible=1
  elif [ "$windows" -gt 0 ]; then
    "$SKETCHYBAR_BIN" --set "space.${sid}" \
      drawing=on \
      icon="$label" \
      icon.color="$SPACE_OCCUPIED_ICON" \
      background.color="$SPACE_BG" \
      background.border_color="$SPACE_BORDER" \
      background.shadow.drawing=off \
      background.drawing=on
    is_visible=1
  else
    "$SKETCHYBAR_BIN" --set "space.${sid}" \
      drawing=off \
      icon="$label" \
      icon.color="$MUTED" \
      background.color="$SPACE_BG" \
      background.border_color="$SPACE_BORDER" \
      background.shadow.drawing=off \
      background.drawing=off
  fi

  if [ "$is_visible" -eq 1 ]; then
    [ -n "$previous_visible" ] && gap_after_spaces="${gap_after_spaces}${previous_visible} "
    visible_spaces="${visible_spaces}${sid} "
    previous_visible="$sid"
    any_visible=1
  fi
done

spacer_state="${visible_spaces}|${gap_after_spaces}"
previous_spacer_state="$(sed -n '1p' "$spacer_state_file" 2>/dev/null || true)"

if [ "$spacer_state" != "$previous_spacer_state" ]; then
  set --

  for sid in 1 2 3 4 5 6 7 8 9 10; do
    case " $gap_after_spaces " in
      *" $sid "*) gap_state="on" ;;
      *) gap_state="off" ;;
    esac

    set -- "$@" --set "space_gap.${sid}" "drawing=${gap_state}"
  done

  if [ "$any_visible" -eq 1 ]; then
    set -- "$@" --set left_gap.sun_workspaces drawing=on --set left_gap.workspaces_app drawing=on
  else
    set -- "$@" --set left_gap.sun_workspaces drawing=off --set left_gap.workspaces_app drawing=off
  fi

  "$SKETCHYBAR_BIN" "$@"
  printf '%s\n' "$spacer_state" > "$spacer_state_file"
fi
