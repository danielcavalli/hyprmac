if command -v nvim >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-nvim}"
else
  export EDITOR="${EDITOR:-vi}"
fi

if command -v zed >/dev/null 2>&1; then
  export VISUAL="${VISUAL:-zed --wait}"
elif [ -x /Applications/Zed.app/Contents/MacOS/cli ]; then
  export VISUAL="${VISUAL:-/Applications/Zed.app/Contents/MacOS/cli --wait}"
else
  export VISUAL="${VISUAL:-$EDITOR}"
fi

export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"
