---
description: Start or continue the Solar Glass workstation Installer Agent
agent: installer
---

Start or continue installing this repository as the Solar Glass Workstation.

Use the project Installer Agent. Start conversationally: briefly explain the workstation and `hyprmac`, ask what the user wants to customize, and offer a read-only inventory. After the user agrees, read installer state, inspect the machine, summarize what exists/missing/blocked, and proceed step by step.

If setup is blocked by Recovery, reboot, permissions, package installation, or user choice, write the checkpoint to the state file and give the user the exact next command to resume.
