---
description: Start or continue the Solar Glass workstation Installer Agent
agent: installer
---

Start or continue installing this repository as the Solar Glass Workstation.

Use the project Installer Agent. Start conversationally: briefly explain the workstation and `hyprmac`, ask what the user wants to customize, and offer deterministic installer inventory. After the user agrees, run the repo installer surface: `./home/.local/bin/hyprmac installer state init`, `./home/.local/bin/hyprmac installer inventory`, and `./home/.local/bin/hyprmac installer gates` with `HYPRMAC_DOTFILES_DIR="$PWD"`. Treat gate output as authoritative and proceed step by step.

If setup is blocked by Recovery, reboot, permissions, package installation, or user choice, write the checkpoint to the state file and give the user the exact next command to resume.
