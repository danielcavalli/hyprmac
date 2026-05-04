tap "koekeishiya/formulae"
tap "felixkratz/formulae"

# Shell and Unix base
brew "bash"
brew "bash-completion@2"
brew "coreutils"
brew "findutils"
brew "gnu-sed"
brew "gawk"
brew "grep"
brew "curl"
brew "wget"

# Developer CLI
brew "git"
brew "gh"
brew "gnupg"
brew "pinentry-mac"
brew "opencode"
brew "git-delta"
brew "jq"
brew "yq"
brew "fzf"
brew "ripgrep"
brew "fd"
brew "eza"
brew "bat"
brew "tree"
brew "watch"
brew "stow"
brew "just"

# Shell UX
brew "mise"
brew "uv"
brew "starship"
brew "direnv"
brew "zoxide"
brew "lazygit"
brew "btop"
brew "neovim"
brew "tmux"

# Language tooling selected for this machine
brew "pnpm"
brew "zig"
brew "zls"

# macOS window-management stack
brew "koekeishiya/formulae/yabai"
brew "koekeishiya/formulae/skhd"
brew "felixkratz/formulae/sketchybar"
brew "felixkratz/formulae/borders"
brew "blueutil"
brew "switchaudio-osx"
brew "nowplaying-cli"

# Validation and formatting
brew "shellcheck"
brew "shfmt"

cask "ghostty"
cask "zed"
cask "raycast"
cask "font-jetbrains-mono-nerd-font"

local = File.expand_path("Brewfile.local", __dir__)
eval(File.read(local), binding, local) if File.exist?(local)
