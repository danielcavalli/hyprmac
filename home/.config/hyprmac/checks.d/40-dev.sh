#!/usr/bin/env bash
set -u

missing=0

runtime_path() {
  local cmd="$1"

  if command -v "$cmd" >/dev/null 2>&1; then
    command -v "$cmd"
    return 0
  fi

  if command -v mise >/dev/null 2>&1; then
    mise which "$cmd" 2>/dev/null && return 0
  fi

  return 1
}

for cmd in bash git gh mise uv python node npm pnpm bun zig zls nvim lazygit btop starship jq; do
  if path="$(runtime_path "$cmd")"; then
    printf 'ok: %s -> %s\n' "$cmd" "$path"
  else
    printf 'missing: %s\n' "$cmd"
    missing=1
  fi
done

exit "$missing"
