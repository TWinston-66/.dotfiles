#!/usr/bin/env bash

set -euo pipefail

# The SSH key lives at the top of the drive labelled DB, which macOS mounts at /Volumes/DB
# and Fedora leaves unmounted until asked. The machine's key is replaced with it (the old
# one kept as id_ed25519.old), and a drive this mounted is unmounted after.
install_ssh_key() {
  local key="$HOME/.ssh/id_ed25519" mount="" mounted=0

  case "$DOTFILES_OS" in
  macos)
    if [ -d /Volumes/DB ]; then mount=/Volumes/DB; fi
    ;;
  fedora)
    if [ -e /dev/disk/by-label/DB ]; then
      mount="$(findmnt -n -o TARGET /dev/disk/by-label/DB | head -n 1 || true)"
      if [ -z "$mount" ]; then
        udisksctl mount --no-user-interaction -b /dev/disk/by-label/DB >/dev/null
        mount="$(findmnt -n -o TARGET /dev/disk/by-label/DB | head -n 1)"
        mounted=1
      fi
    fi
    ;;
  esac

  if [ -z "$mount" ] || [ ! -f "$mount/id_ed25519" ] || [ ! -f "$mount/id_ed25519.pub" ]; then
    log_info "No SSH key found on a drive labelled DB; the SSH key stays as it is"
  elif cmp -s "$mount/id_ed25519" "$key" && cmp -s "$mount/id_ed25519.pub" "$key.pub"; then
    log_info "SSH key already matches the DB drive's"
  else
    log_step "Installing the SSH key from the DB drive"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    if [ -f "$key" ]; then
      mv -f "$key" "$key.old"
      if [ -f "$key.pub" ]; then mv -f "$key.pub" "$key.pub.old"; fi
      log_info "Previous key kept as $key.old"
    fi
    # exFAT has no permissions, so the copies get ssh's.
    install -m 600 "$mount/id_ed25519" "$key"
    install -m 644 "$mount/id_ed25519.pub" "$key.pub"
    log_info "$(ssh-keygen -l -f "$key.pub")"
  fi

  if [ "$mounted" -eq 1 ]; then
    udisksctl unmount --no-user-interaction -b /dev/disk/by-label/DB >/dev/null || true
  fi
}
