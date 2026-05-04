# Zed

Zed is the opinionated GUI editor for Hyprmac. Neovim stays available in Ghostty, but Zed is preinstalled and preconfigured for project work when a native macOS editor is the better tool.

## Install

`Brewfile` installs Zed with:

```sh
cask "zed"
```

The tracked config lives in `home/.config/zed` and is installed to `~/.config/zed` by the dotfiles flow.

## Defaults

- VS Code-like base keymap for low-friction editing.
- Ayu Light/Mirage theme pair to fit the warm Solar Glass direction.
- `SF Pro Text` UI font and `JetBrainsMono Nerd Font` buffer font.
- Homebrew Bash login shell for Zed's integrated terminal.
- `direnv` is loaded directly so project toolchains are visible to Zed.
- Zed self-update and telemetry are disabled; Homebrew and this repo own the setup.
- Format-on-save for code, with Markdown left unformatted by default.
- Language spacing defaults for JSON, Markdown, Python, shell, TypeScript, and Zig.

## Launching

```text
Super+Shift+Z    Open Zed
```

Shell helpers are loaded when the Zed CLI is available:

```sh
ze <path>
zedp
zedw <path>
```

The shell keeps `EDITOR` as a terminal editor (`nvim` or `vi`) and sets `VISUAL` to `zed --wait` when the Zed CLI or app-bundle CLI is available.

## Diagnostics

```sh
hyprmac dev doctor
hyprmac docs zed
```

`hyprmac dev doctor` checks for Zed, the Zed CLI fallback, and tracked Zed config under `~/.config/zed`.
