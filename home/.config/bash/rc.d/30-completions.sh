if [ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
  . /opt/homebrew/etc/profile.d/bash_completion.sh
fi

command -v mise >/dev/null 2>&1 && eval "$(mise completion bash)"
command -v gh >/dev/null 2>&1 && eval "$(gh completion -s bash)"
