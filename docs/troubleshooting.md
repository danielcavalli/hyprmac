# Troubleshooting

## Permissions

Grant Accessibility permissions to:
- `yabai`
- `skhd`
- `Ghostty` if global shortcuts are enabled later

Open:

```sh
open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'
```

## Xcode Command Line Tools

`brew bundle` can block or fail until Apple's Command Line Tools are installed.

```sh
xcode-select -p
xcode-select --install
```

## Services

If `skhd` reports a config load error for `skhdrc.local`, create the ignored local file first:

```sh
cp ~/.config/skhd/skhdrc.local.example ~/.config/skhd/skhdrc.local
```

```sh
brew services list
yabai --restart-service
skhd --restart-service
brew services restart sketchybar
brew services restart borders
```

Logs:

```sh
tail -f /tmp/yabai_$USER.err.log
tail -f /tmp/skhd_$USER.err.log
```

## SketchyBar Not Updating Spaces

```sh
sketchybar --reload
yabai -m signal --list
```

If signals are duplicated, restart `yabai` and `sketchybar`:

```sh
hyprmac reload
```

## Restore Native UI

```sh
defaults write NSGlobalDomain _HIHideMenuBar -bool false
defaults write com.apple.dock autohide -bool false
killall Dock
```

## Shell Rollback

```sh
chsh -s /bin/zsh
```
