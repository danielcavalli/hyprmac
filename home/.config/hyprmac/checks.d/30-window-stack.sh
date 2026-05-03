#!/usr/bin/env bash
set -u

missing=0
YABAI_BIN="${YABAI_BIN:-/opt/homebrew/bin/yabai}"
[ -x "$YABAI_BIN" ] || YABAI_BIN="$(command -v yabai 2>/dev/null || printf '%s' /opt/homebrew/bin/yabai)"
HYPRMAC_USER="${HYPRMAC_USER:-$(stat -f %Su "$HOME" 2>/dev/null || id -un)}"
HYPRMAC_UID="${HYPRMAC_UID:-$(id -u "$HYPRMAC_USER" 2>/dev/null || id -u)}"
HYPRMAC_HOME="${HYPRMAC_HOME:-$(dscl . -read "/Users/${HYPRMAC_USER}" NFSHomeDirectory 2>/dev/null | awk '{print $2}' || true)}"
HYPRMAC_HOME="${HYPRMAC_HOME:-$HOME}"

as_target_user() {
  if [ "$(id -u)" = "$HYPRMAC_UID" ]; then
    env HOME="$HYPRMAC_HOME" USER="$HYPRMAC_USER" LOGNAME="$HYPRMAC_USER" PATH="$PATH" "$@"
  elif [ "$(id -u)" = "0" ]; then
    sudo -u "$HYPRMAC_USER" env HOME="$HYPRMAC_HOME" USER="$HYPRMAC_USER" LOGNAME="$HYPRMAC_USER" PATH="$PATH" "$@"
  else
    env HOME="$HYPRMAC_HOME" USER="$HYPRMAC_USER" LOGNAME="$HYPRMAC_USER" PATH="$PATH" "$@"
  fi
}

for cmd in yabai skhd sketchybar borders jq; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf 'ok: %s -> %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf 'missing: %s\n' "$cmd"
    missing=1
  fi
done

if command -v brew >/dev/null 2>&1; then
  as_target_user env HOMEBREW_SERVICES_NO_DOMAIN_WARNING=1 HOMEBREW_NO_ENV_HINTS=1 brew services list | grep -E 'yabai|skhd|sketchybar|borders' || true
fi

launchctl print "gui/${HYPRMAC_UID}" 2>/dev/null | grep -E 'com.asmvik.yabai|com.koekeishiya.skhd|homebrew.mxcl.sketchybar|homebrew.mxcl.borders|git.felix.sketchybar|git.felix.borders' || true

if [ -x "$YABAI_BIN" ]; then
  if as_target_user "$YABAI_BIN" -m query --spaces >/dev/null 2>&1; then
    printf 'ok: yabai space query\n'
  else
    printf 'missing: yabai space query failed\n'
    missing=1
  fi
fi

exit "$missing"
