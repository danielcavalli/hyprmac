#!/usr/bin/env bash
set -u

missing=0
product_version="$(sw_vers -productVersion 2>/dev/null || true)"
arch="$(uname -m)"

sw_vers
printf 'arch: %s\n' "$arch"

if [ "$arch" != "arm64" ]; then
  printf 'unsupported: Apple Silicon arm64 is required\n'
  missing=1
fi

case "${product_version%%.*}" in
  ''|*[!0-9]*) ;;
  *)
    if [ "${product_version%%.*}" -lt 26 ]; then
      printf 'unsupported: macOS 26 or newer is expected\n'
      missing=1
    fi
    ;;
esac

HYPRMAC_USER="${HYPRMAC_USER:-$(stat -f %Su "$HOME" 2>/dev/null || id -un)}"
login_shell="$(dscl . -read "/Users/${HYPRMAC_USER}" UserShell 2>/dev/null | awk '{print $2}')"
printf 'user: %s\n' "$HYPRMAC_USER"
printf 'login shell: %s\n' "${login_shell:-${SHELL:-unknown}}"

if xcode-select -p >/dev/null 2>&1; then
  printf 'xcode clt: %s\n' "$(xcode-select -p)"
else
  printf 'missing: Xcode Command Line Tools. Run: xcode-select --install\n'
  exit 1
fi

if command -v brew >/dev/null 2>&1; then
  printf 'brew: %s\n' "$(command -v brew)"
else
  printf 'missing: brew\n'
  exit 1
fi

exit "$missing"
