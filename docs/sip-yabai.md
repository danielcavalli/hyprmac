# SIP And Full Yabai

Full `yabai` support on Apple Silicon requires partial SIP changes. This enables scripting-addition features such as advanced space control, sticky windows, layers, opacity, shadows, and more reliable space/window operations.

## What SIP Is

SIP means System Integrity Protection. It is a macOS security system that prevents even `root` from modifying or injecting into protected system processes.

Full `yabai` needs to inject a scripting addition into `Dock.app`, because Dock owns macOS Spaces. Without this, basic tiling can work, but several Omarchy-like workspace features are limited or unreliable.

We are not fully disabling SIP. We are partially relaxing the pieces `yabai` needs:

```text
fs      filesystem protections needed for scripting additions
debug   process/debug restrictions needed for Dock injection
nvram   lets us set the arm64e boot arg used by yabai on Apple Silicon
```

This reduces macOS security. Only use the full-yabai path if you accept that tradeoff for this workstation.

## 1. Enter Recovery Mode On Apple Silicon

You cannot run `csrutil` from normal macOS. You must boot into Recovery Mode.

Steps:

1. Save your work.
2. Open Apple menu > Shut Down.
3. Wait until the screen is fully black.
4. Press and hold the power button. Do not just tap it.
5. Keep holding until you see `Loading startup options`.
6. Click `Options`.
7. Click `Continue`.
8. Select your admin user if asked.
9. Enter your password if asked.
10. In the top menu bar, open `Utilities > Terminal`.

You should now see a Recovery Terminal window.

Run this exactly:

Run:

```sh
csrutil enable --without fs --without debug --without nvram
```

Reboot into macOS.

In Recovery, you can reboot from Apple menu > Restart, or run:

```sh
reboot
```

## 2. Normal macOS Boot Args

After rebooting into macOS, run:

```sh
hyprmac sip enable-arm64e
```

Reboot again.

This preserves existing boot args, adds `-arm64e_preview_abi` if missing, and requires a second reboot for the Apple Silicon `arm64e` boot argument to take effect.

## 3. Configure Yabai Sudoers

After Homebrew installs `yabai`:

```sh
hyprmac yabai sudoers
```

This creates `/private/etc/sudoers.d/yabai` with the current `yabai` binary hash. Re-run it after every `yabai` upgrade because the hash changes.

## 4. Load Scripting Addition

```sh
hyprmac yabai load-sa
hyprmac yabai ensure-spaces 10
```

## 5. Verify

```sh
csrutil status
nvram boot-args
sysctl -n kern.bootargs
yabai -m query --spaces
hyprmac doctor
```

Expected `hyprmac doctor` changes after the full setup:

```text
SIP should no longer report the default fully-enabled state.
boot-args should include -arm64e_preview_abi.
yabai query should work.
```

macOS may show `unknown` or a custom SIP state after partial SIP changes. That is normal for this setup.

## Rollback

Boot Recovery and run:

```sh
csrutil enable
```

After rebooting into macOS:

```sh
hyprmac sip disable-arm64e
sudo rm -f /private/etc/sudoers.d/yabai
sudo yabai --uninstall-sa
```

`hyprmac sip disable-arm64e` removes only `-arm64e_preview_abi` and preserves unrelated boot args.
