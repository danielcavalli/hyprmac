export NODE_OPTIONS="${NODE_OPTIONS:---enable-source-maps}"
export PYTHONUNBUFFERED="${PYTHONUNBUFFERED:-1}"
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
