#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER=""
TARGET_UID=""
TARGET_HOME=""
USER_PATH=""

MODE="tui"
MODEL="${OPENCODE_MODEL:-}"
DRY_RUN=0
SKIP_XCODE_UPDATE_CHECK=0
NO_BREW_INSTALL=0
NO_OPENCODE_INSTALL=0

usage() {
  cat <<'EOF'
Usage: sudo ./install.sh [options]

This is only the bootstrap scaffold for the OpenCode Installer Agent.
It verifies prerequisite tooling, installs missing bootstrap tools when approved,
then launches OpenCode with the project `installer` agent.

Options:
  --tui                       Launch interactive OpenCode TUI (default)
  --run                       Launch non-interactive `opencode run`
  --model PROVIDER/MODEL      Pass a model to OpenCode
  --dry-run                   Print checks and launch command without starting OpenCode
  --skip-xcode-update-check   Skip `softwareupdate` developer-tool update check
  --no-brew-install           Do not offer Homebrew installation if missing
  --no-opencode-install       Do not offer OpenCode installation if missing
  -h, --help                  Show this help

Continuity:
  If the Installer Agent pauses for Recovery, reboot, or a failed prerequisite,
  return to this repository and run `sudo ./install.sh` again. The shell scaffold
  will re-check prerequisites and launch the agent, which resumes from its state
  file at ~/.local/state/hyprmac-installer/state.md.
EOF
}

info() {
  printf '%s\n' "$*"
}

warn() {
  printf 'warn: %s\n' "$*" >&2
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

confirm() {
  local prompt="$1"
  local default="${2:-yes}"
  local suffix answer

  if [ "$default" = "yes" ]; then
    suffix="Y/n"
  else
    suffix="y/N"
  fi

  printf '%s [%s] ' "$prompt" "$suffix"
  read -r answer
  answer="${answer:-$default}"

  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --tui) MODE="tui" ;;
      --run) MODE="run" ;;
      --model)
        shift
        [ "$#" -gt 0 ] || fail "--model requires a value"
        MODEL="$1"
        ;;
      --dry-run) DRY_RUN=1 ;;
      --skip-xcode-update-check) SKIP_XCODE_UPDATE_CHECK=1 ;;
      --no-brew-install) NO_BREW_INSTALL=1 ;;
      --no-opencode-install) NO_OPENCODE_INSTALL=1 ;;
      -h|--help) usage; exit 0 ;;
      *) fail "unknown option: $1" ;;
    esac
    shift
  done
}

detect_target() {
  local repo_owner

  if [ "$(id -u)" = "0" ]; then
    if [ -n "${HYPRMAC_TARGET_USER:-}" ]; then
      TARGET_USER="$HYPRMAC_TARGET_USER"
    elif [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
      TARGET_USER="$SUDO_USER"
    else
      repo_owner="$(stat -f %Su "$DOTFILES_DIR" 2>/dev/null || true)"
      [ "$repo_owner" != "root" ] && TARGET_USER="$repo_owner"
    fi
  else
    TARGET_USER="$(id -un)"
  fi

  [ -n "$TARGET_USER" ] || fail "could not determine target user; run as your macOS user with sudo ./install.sh"
  TARGET_UID="$(id -u "$TARGET_USER" 2>/dev/null || true)"
  [ -n "$TARGET_UID" ] || fail "target user does not exist: $TARGET_USER"

  TARGET_HOME="$(dscl . -read "/Users/${TARGET_USER}" NFSHomeDirectory 2>/dev/null | awk '{print $2}' || true)"
  [ -n "$TARGET_HOME" ] || TARGET_HOME="$(eval printf '%s' "~$TARGET_USER")"
  [ -d "$TARGET_HOME" ] || fail "target home does not exist: $TARGET_HOME"

  USER_PATH="$TARGET_HOME/.local/bin:$TARGET_HOME/.local/share/mise/shims:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
}

as_user() {
  if [ "$(id -u)" = "$TARGET_UID" ]; then
    env HOME="$TARGET_HOME" USER="$TARGET_USER" LOGNAME="$TARGET_USER" PATH="$USER_PATH:${PATH:-}" "$@"
  elif [ "$(id -u)" = "0" ]; then
    sudo -u "$TARGET_USER" env HOME="$TARGET_HOME" USER="$TARGET_USER" LOGNAME="$TARGET_USER" PATH="$USER_PATH:${PATH:-}" "$@"
  else
    env HOME="$TARGET_HOME" USER="$TARGET_USER" LOGNAME="$TARGET_USER" PATH="$USER_PATH:${PATH:-}" "$@"
  fi
}

command_as_user() {
  as_user sh -lc "$1"
}

bootstrap_banner() {
  cat <<EOF
Solar Glass Workstation bootstrap scaffold

Target user: $TARGET_USER
Target home: $TARGET_HOME
Repository:  $DOTFILES_DIR

This shell script only prepares the OpenCode Installer Agent.
The actual workstation installation and customization happens inside OpenCode.
EOF
}

check_xcode_tools() {
  local clt_path clt_version update_output

  if ! clt_path="$(xcode-select -p 2>/dev/null)"; then
    cat <<'EOF'

Xcode Command Line Tools are required before installation can continue.
The installer will open Apple's installer prompt now.
After it finishes, return to this repository and run:

  sudo ./install.sh
EOF
    xcode-select --install >/dev/null 2>&1 || true
    exit 20
  fi

  info "ok: Xcode Command Line Tools -> $clt_path"
  clt_version="$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null | awk -F ': ' '/version/{print $2; exit}' || true)"
  [ -n "$clt_version" ] && info "ok: CLT version -> $clt_version"

  if [ "$SKIP_XCODE_UPDATE_CHECK" -eq 1 ]; then
    warn "skipped Xcode/CLT update check"
    return 0
  fi

  info "checking for developer tool updates..."
  update_output="$(softwareupdate -l 2>&1 || true)"
  if printf '%s\n' "$update_output" | grep -Eiq 'Command Line Tools|Xcode'; then
    cat <<EOF

Developer tool updates appear to be available:

$(printf '%s\n' "$update_output" | grep -Ei 'Command Line Tools|Xcode' || true)

Install them from System Settings > General > Software Update, or with the
softwareupdate command if you prefer. Then return and run:

  sudo ./install.sh
EOF
  else
    info "ok: no Xcode/CLT update found by softwareupdate"
  fi
}

ensure_homebrew() {
  if command_as_user 'command -v brew >/dev/null 2>&1'; then
    info "ok: Homebrew -> $(command_as_user 'command -v brew')"
    return 0
  fi

  if [ "$NO_BREW_INSTALL" -eq 1 ]; then
    fail "Homebrew is missing. Install it from https://brew.sh, then rerun sudo ./install.sh"
  fi

  cat <<'EOF'

Homebrew is required so the Installer Agent can install workstation tooling.
This scaffold can run the official Homebrew installer as the target user.
EOF

  if confirm "Install Homebrew now?" yes; then
    # Run the official installer as the target user; it performs its own prompts.
    # shellcheck disable=SC2016
    as_user /bin/bash -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  else
    fail "Homebrew installation skipped. Install Homebrew, then rerun sudo ./install.sh"
  fi

  command_as_user 'command -v brew >/dev/null 2>&1' || fail "Homebrew still not found after installation"
  info "ok: Homebrew -> $(command_as_user 'command -v brew')"
}

ensure_opencode() {
  if command_as_user 'command -v opencode >/dev/null 2>&1'; then
    info "ok: OpenCode -> $(command_as_user 'command -v opencode')"
    return 0
  fi

  if [ "$NO_OPENCODE_INSTALL" -eq 1 ]; then
    fail "OpenCode is missing. Install it with brew install opencode, then rerun sudo ./install.sh"
  fi

  cat <<'EOF'

OpenCode is required because the Installer Agent is the installation process.
The scaffold will install OpenCode with Homebrew as the target user.
EOF

  if confirm "Install OpenCode now?" yes; then
    as_user brew install opencode
  else
    fail "OpenCode installation skipped. Install OpenCode, then rerun sudo ./install.sh"
  fi

  command_as_user 'command -v opencode >/dev/null 2>&1' || fail "OpenCode still not found after installation"
  info "ok: OpenCode -> $(command_as_user 'command -v opencode')"
}

build_agent_prompt() {
  cat <<EOF
Start or continue installing the Solar Glass Workstation from this repository.

The shell scaffold has completed its prerequisite role:
- target user: $TARGET_USER
- target home: $TARGET_HOME
- repository: $DOTFILES_DIR
- Homebrew is available
- Xcode Command Line Tools are available
- OpenCode is available

You are the Installer Agent. The shell script is not the installer; it only ensured this session can run.

Start conversationally. Do not run tools in your first response unless the user explicitly asks you to check or continue immediately. Briefly explain the workstation, explain hyprmac as the command center, ask what the user wants to customize, and offer deterministic installer inventory as the next step.

After the user agrees to a check, use the repository installer surface instead of ad hoc guesses:

  HYPRMAC_DOTFILES_DIR="$DOTFILES_DIR" $DOTFILES_DIR/home/.local/bin/hyprmac installer state init
  HYPRMAC_DOTFILES_DIR="$DOTFILES_DIR" $DOTFILES_DIR/home/.local/bin/hyprmac installer inventory
  HYPRMAC_DOTFILES_DIR="$DOTFILES_DIR" $DOTFILES_DIR/home/.local/bin/hyprmac installer gates

Treat gate output as authoritative: ok means ready, warn means non-blocking, fail means repairable in this macOS session, and block means pause for Recovery, reboot, or explicit approval.

If setup is blocked by Recovery, reboot, package failure, or user choice, write the checkpoint to the state file and tell the user to return to this repository and run:

  sudo ./install.sh
EOF
}

launch_opencode() {
  local launch_line prompt
  prompt="$(build_agent_prompt)"

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ "$MODE" = "run" ]; then
      launch_line="opencode run --agent installer --dir $DOTFILES_DIR"
    else
      launch_line="opencode $DOTFILES_DIR --agent installer"
    fi
    cat <<EOF

Would launch OpenCode with:
  $launch_line

Prompt:
$prompt
EOF
    return 0
  fi

  if [ "$MODE" = "run" ]; then
    if [ -n "$MODEL" ]; then
      as_user opencode run --agent installer --dir "$DOTFILES_DIR" --model "$MODEL" "$prompt"
    else
      as_user opencode run --agent installer --dir "$DOTFILES_DIR" "$prompt"
    fi
  else
    if [ -n "$MODEL" ]; then
      as_user opencode "$DOTFILES_DIR" --agent installer --model "$MODEL" --prompt "$prompt"
    else
      as_user opencode "$DOTFILES_DIR" --agent installer --prompt "$prompt"
    fi
  fi
}

main() {
  parse_args "$@"
  detect_target
  bootstrap_banner
  check_xcode_tools
  ensure_homebrew
  ensure_opencode
  launch_opencode
}

main "$@"
