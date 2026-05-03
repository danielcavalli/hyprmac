#!/usr/bin/env sh

. "${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/lib.sh"

app="${INFO:-}"

if [ -z "$app" ]; then
  app="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null || true)"
fi

[ -n "$app" ] || app="Desktop"

case "$app" in
  ghostty) app="Ghostty" ;;
  finder) app="Finder" ;;
  safari) app="Safari" ;;
  arc) app="Arc" ;;
  "google chrome") app="Google Chrome" ;;
  firefox) app="Firefox" ;;
  code) app="Code" ;;
  cursor) app="Cursor" ;;
  zed) app="Zed" ;;
  slack) app="Slack" ;;
  discord) app="Discord" ;;
  messages) app="Messages" ;;
  mail) app="Mail" ;;
  calendar) app="Calendar" ;;
  reminders) app="Reminders" ;;
  notes) app="Notes" ;;
  music) app="Music" ;;
  spotify) app="Spotify" ;;
  "system settings") app="System Settings" ;;
esac

icon="󰣆"
color="$CYAN"

case "$app" in
  Ghostty|Terminal|iTerm2)
    icon="󰆍"
    color="$AMBER"
    ;;
  Finder)
    icon="󰀶"
    color="$BLUE"
    ;;
  Safari|Arc|Google\ Chrome|Firefox)
    icon="󰖟"
    color="$BLUE"
    ;;
  Code|Cursor|Zed|Neovide)
    icon="󰨞"
    color="$PURPLE"
    ;;
  Slack|Discord|Messages)
    icon="󰍡"
    color="$CYAN"
    ;;
  Mail|Calendar|Reminders|Notes)
    icon="󰇮"
    color="$LIME"
    ;;
  Music|Spotify)
    icon="󰝚"
    color="$ROSE"
    ;;
  "System Settings")
    icon="󰒓"
    color="$MUTED"
    ;;
esac

"$SKETCHYBAR_BIN" --set "$NAME" icon="$icon" icon.color="$color" label="$app"
