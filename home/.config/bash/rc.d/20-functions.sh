# shellcheck shell=bash

mkcd() {
  mkdir -p "$1" && cd "$1" || return
}

take() {
  mkcd "$1"
}

serve() {
  local port="${1:-8000}"
  python3 -m http.server "$port"
}

path() {
  tr ':' '\n' <<< "$PATH"
}

extract() {
  [ -f "$1" ] || {
    printf 'extract: not a file: %s\n' "$1" >&2
    return 1
  }

  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) printf 'extract: unsupported archive: %s\n' "$1" >&2; return 1 ;;
  esac
}
