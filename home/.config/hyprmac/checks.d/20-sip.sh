#!/usr/bin/env bash
set -u

missing=0
status="$(csrutil status 2>/dev/null || true)"
printf '%s\n' "$status"

boot_args="$(nvram boot-args 2>/dev/null || true)"
boot_args="${boot_args#boot-args}"
active_boot_args="$(sysctl -n kern.bootargs 2>/dev/null || true)"

if printf '%s' "$boot_args" | grep -q -- '-arm64e_preview_abi'; then
  printf 'nvram boot-args:%s\n' "$boot_args"
else
  printf 'nvram boot-args: missing -arm64e_preview_abi\n'
  printf 'next: hyprmac sip enable-arm64e, then reboot\n'
  missing=1
fi

if printf '%s' "$active_boot_args" | grep -q -- '-arm64e_preview_abi'; then
  printf 'active boot-args: %s\n' "$active_boot_args"
else
  printf 'active boot-args: missing -arm64e_preview_abi\n'
  if printf '%s' "$boot_args" | grep -q -- '-arm64e_preview_abi'; then
    printf 'next: reboot so the kernel applies the persisted boot arg\n'
  fi
  missing=1
fi

if printf '%s\n' "$status" | grep -q 'Filesystem Protections: disabled' \
  && printf '%s\n' "$status" | grep -q 'Debugging Restrictions: disabled' \
  && printf '%s\n' "$status" | grep -q 'NVRAM Protections: disabled' \
  && printf '%s\n' "$status" | grep -q 'Boot-arg Restrictions: disabled'; then
  printf 'ok: partial SIP state matches docs/sip-yabai.md\n'
else
  printf 'missing: partial SIP changes from docs/sip-yabai.md\n'
  missing=1
fi

exit "$missing"
