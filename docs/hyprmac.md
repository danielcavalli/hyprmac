# Hyprmac CLI

`hyprmac` is the local operator CLI for this macOS workstation. It keeps the original install/recovery commands, but also exposes a `hyprctl`-style control surface over yabai, skhd, SketchyBar, and macOS.

## Hyprctl-Style Surface

```sh
hyprmac version
hyprmac -j version
hyprmac monitors
hyprmac workspaces
hyprmac activeworkspace
hyprmac clients
hyprmac activewindow
hyprmac query rules
hyprmac query signals
hyprmac query binds
hyprmac getoption window_gap
hyprmac keyword window_gap 10
```

Use `-r` when a mutating command should trigger SketchyBar refresh events after it runs:

```sh
hyprmac -r keyword window_gap 12
hyprmac -r dispatch movetoworkspacefollow ws4
```

## Dispatch

`dispatch` is the action layer. It maps Hyprland-like actions to the macOS backend.

```sh
hyprmac dispatch focusworkspace ws2
hyprmac dispatch movetoworkspace ws3
hyprmac dispatch movetoworkspacefollow ws4
hyprmac dispatch focuswindow west
hyprmac dispatch swapwindow east
hyprmac dispatch warpwindow north
hyprmac dispatch stackwindow recent
hyprmac dispatch changegroupactive next
hyprmac dispatch togglefloating
hyprmac dispatch fullscreen
hyprmac dispatch fullscreenparent
hyprmac dispatch togglesplit
hyprmac dispatch layout stack
hyprmac dispatch togglelayout
hyprmac dispatch togglegaps
hyprmac dispatch togglepadding
hyprmac dispatch movetoscratchpad
hyprmac dispatch scratchpad
hyprmac dispatch closewindow
```

`closewindow` uses the repository's focused-window close policy: it targets the focused window/PID and does not quit every window owned by the app bundle.

## Raw Backends

Use `raw` when you want direct backend access without remembering paths or target-user handling.

```sh
hyprmac raw yabai-m query --windows --window
hyprmac raw yabai --version
hyprmac raw sketchybar --query bar
hyprmac raw skhd -v
hyprmac raw brew services list
hyprmac raw launchctl print gui/$(id -u)
hyprmac raw shell 'date; whoami'
```

## Batch

`batch` runs semicolon-separated `hyprmac` commands in order.

```sh
hyprmac batch 'dispatch focusworkspace ws2; dispatch layout bsp; query activeworkspace'
hyprmac --batch 'keyword window_gap 8; dispatch togglesplit'
```

## Notifications

`notify` uses SketchyBar when available, with an AppleScript notification fallback.

```sh
hyprmac notify 'Reload complete'
hyprmac notify -1 5000 'rgb(ffb454)' 'Window moved'
hyprmac dismissnotify
```

## Existing Operational Commands

The original command-center flows remain available:

```sh
hyprmac doctor
hyprmac reload
hyprmac update
hyprmac sip
hyprmac sip enable-arm64e
hyprmac sip disable-arm64e
hyprmac yabai status
hyprmac yabai restart
hyprmac yabai sudoers
hyprmac yabai load-sa
hyprmac yabai ensure-spaces 10
hyprmac skhd status
hyprmac bar status
hyprmac bar toggle
hyprmac power
hyprmac macos defaults
hyprmac installer inventory
hyprmac installer gates
hyprmac installer link
hyprmac installer overrides
hyprmac installer state path
hyprmac dev doctor
hyprmac docs design
hyprmac theme current
```
