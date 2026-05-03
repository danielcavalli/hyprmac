# Installer Agent

This repository ships a small shell bootstrap scaffold and an OpenCode Installer Agent.

The shell scaffold is not the installer. It only verifies the prerequisites needed to start the agent:

- Homebrew
- Xcode Command Line Tools
- developer-tool update visibility
- OpenCode

Start with:

```sh
sudo ./install.sh
```

After prerequisites are ready, the scaffold launches the OpenCode Installer Agent.

The installer is an OpenCode project agent located at:

```text
.opencode/agents/installer.md
```

You can also start the agent manually with:

```sh
opencode . --agent installer
```

Or from inside OpenCode:

```text
/install
```

For non-interactive mode:

```sh
opencode run --agent installer --dir . "Start installation"
```

The agent starts with a short onboarding conversation, not a batch of commands. First it explains the workstation and `hyprmac`, asks what you care about, and offers to run a read-only check.

The agent profile is intentionally trusted for installation work: shell execution and external directory access are pre-approved so inventory commands, `hyprmac` commands, Homebrew/service checks, and `~/.local/state/hyprmac-installer/` reads do not create repeated OpenCode permission prompts. The agent still asks conversationally before invasive or destructive work.

After you approve that check, it confirms:

- what already exists
- what is missing
- what is already running
- what is blocked by permissions, Recovery, reboot, or user choice

Then it asks for customization preferences, applies setup directly, and writes continuity state to:

```text
~/.local/state/hyprmac-installer/state.md
```

If setup pauses for Recovery or a reboot, return to the repository and run:

```sh
sudo ./install.sh
```

The scaffold will relaunch the agent. If you prefer to bypass the scaffold after prerequisites are ready, use:

```sh
opencode . --agent installer
```

The agent will read the state file, re-check the actual machine state, and continue.

## What The Agent Explains

The Installer Agent should be able to explain this repo before modifying it:

- SketchyBar becomes the primary system surface.
- yabai and skhd provide keyboard-driven tiling with Option as Super.
- Ghostty and Homebrew Bash form the terminal and shell core.
- The right-side system controls use custom popups for Wi-Fi, Bluetooth, sound, power, and battery.
- Developer tooling covers Python, Node/Web, Bun, Zig, and ZLS.
- `hyprmac` is the command center for diagnosis, reloads, power, macOS defaults, yabai, skhd, SketchyBar, docs, dev checks, and `hyprctl`-style query/dispatch/raw control.

The agent should not rush into setup. It should explain benefits and tradeoffs briefly, then let the user choose defaults or customize.
