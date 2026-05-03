# ~/.profile
# Login-shell environment. Keep this file POSIX-friendly.

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac

case ":$PATH:" in
  *":$HOME/bin:"*) ;;
  *) PATH="$HOME/bin:$PATH" ;;
esac

export PATH

if [ -n "${BASH_VERSION:-}" ] && [ -z "${DOTFILES_ENV_LOADED:-}" ]; then
  export DOTFILES_ENV_LOADED=1

  for file in "$HOME"/.config/bash/env.d/*.sh; do
    [ -r "$file" ] && . "$file"
  done

  [ -r "$HOME/.config/bash/local.env.sh" ] && . "$HOME/.config/bash/local.env.sh"
fi
