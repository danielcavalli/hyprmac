# Yabai Overrides

Drop executable or sourceable `.sh` files here for ordered overrides.

Examples:

```sh
# 20-work-monitor.sh
"${YABAI_BIN:-/opt/homebrew/bin/yabai}" -m config --space 2 layout float
"${YABAI_BIN:-/opt/homebrew/bin/yabai}" -m rule --add app="^Xcode$" space=2
```

Files are loaded before `~/.config/yabai/yabairc.local`.
