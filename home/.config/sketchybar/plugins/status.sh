#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

mode="$1"

case "$mode" in
  wm)
    if [ -x "$YABAI_BIN" ]; then
      "$YABAI_BIN" -m query --spaces --space >/dev/null 2>&1 || true
      label=""
      icon="◈"
      color="$LIME"
    else
      label=""
      icon="◇"
      color="$MUTED"
    fi
    ;;
  updates)
    if command -v brew >/dev/null 2>&1; then
      state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/sketchybar"
      cache="$state_dir/brew-outdated-count"
      now="$(date +%s)"
      age=999999

      mkdir -p "$state_dir"
      if [ -r "$cache" ]; then
        modified="$(stat -f %m "$cache" 2>/dev/null || printf '0')"
        age=$((now - modified))
      fi

      if [ "$age" -gt 21600 ]; then
        count="$(brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ')"
        printf '%s\n' "${count:-0}" > "$cache"
      else
        count="$(sed -n '1p' "$cache" 2>/dev/null || printf '0')"
      fi

      if [ "${count:-0}" -gt 0 ]; then
        label="$count"
        color="$PURPLE"
      else
        label=""
        color="$MUTED"
      fi
      icon="󰚰"
    else
      label=""
      icon="󰚰"
      color="$MUTED"
    fi
    ;;
  *)
    label=""
    icon="•"
    color="$CYAN"
    ;;
esac

if [ -n "$label" ]; then
  "$SKETCHYBAR_BIN" --set "$NAME" drawing=on icon="$icon" label="$label" label.drawing=on icon.color="$color" background.drawing=on
else
  "$SKETCHYBAR_BIN" --set "$NAME" drawing=off icon="$icon" label.drawing=off icon.color="$color" background.drawing=off
fi
