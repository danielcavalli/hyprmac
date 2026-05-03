# ~/.bashrc
# Bash interactive shell entrypoint.

case $- in
  *i*) ;;
  *) return ;;
esac

if [ -z "${DOTFILES_ENV_LOADED:-}" ]; then
  export DOTFILES_ENV_LOADED=1

  for file in "$HOME"/.config/bash/env.d/*.sh; do
    [ -r "$file" ] && . "$file"
  done

  [ -r "$HOME/.config/bash/local.env.sh" ] && . "$HOME/.config/bash/local.env.sh"
fi

for file in "$HOME"/.config/bash/rc.d/*.sh; do
  [ -r "$file" ] && . "$file"
done

[ -r "$HOME/.config/bash/local.rc.sh" ] && . "$HOME/.config/bash/local.rc.sh"
