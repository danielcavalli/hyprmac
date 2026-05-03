#!/usr/bin/env sh

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
PLUGIN_DIR="${PLUGIN_DIR:-$CONFIG_DIR/plugins}"
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
SKETCHYBAR_BIN="${SKETCHYBAR_BIN:-/opt/homebrew/bin/sketchybar}"
[ -x "$YABAI_BIN" ] || YABAI_BIN="$(command -v yabai 2>/dev/null || printf '%s' /opt/homebrew/bin/yabai)"
[ -x "$SKETCHYBAR_BIN" ] || SKETCHYBAR_BIN="$(command -v sketchybar 2>/dev/null || printf '%s' /opt/homebrew/bin/sketchybar)"
export CONFIG_DIR PLUGIN_DIR YABAI_BIN SKETCHYBAR_BIN

[ -r "$CONFIG_DIR/theme.sh" ] && . "$CONFIG_DIR/theme.sh"
