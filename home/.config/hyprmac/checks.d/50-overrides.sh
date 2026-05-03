#!/usr/bin/env bash
set -u

found=0

for file in \
  "$HOME/.config/bash/local.env.sh" \
  "$HOME/.config/bash/local.rc.sh" \
  "$HOME/.config/yabai/yabairc.local" \
  "$HOME/.config/skhd/skhdrc.local" \
  "$HOME/.config/sketchybar/local.pre.sh" \
  "$HOME/.config/sketchybar/local.post.sh" \
  "$HOME/.config/ghostty/local.config"; do
  if [ -s "$file" ]; then
    printf 'active override: %s\n' "$file"
    found=1
  fi
done

[ "$found" -eq 1 ] || printf 'no active local overrides\n'
