case $- in
  *i*) ;;
  *) return ;;
esac

[ -n "${TMUX:-}" ] && return
[ "${DOTFILES_AUTO_TMUX:-1}" = "1" ] || return
[ -z "${SSH_CONNECTION:-}${SSH_TTY:-}" ] || return
command -v tmux >/dev/null 2>&1 || return

case "${TERM_PROGRAM:-}:${GHOSTTY_RESOURCES_DIR:-}${GHOSTTY_BIN_DIR:-}" in
  ghostty:*|*:*/Ghostty.app/*) ;;
  *) return ;;
esac

tmux new-session -A -s main
exit $?
