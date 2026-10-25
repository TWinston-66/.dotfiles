#!/usr/bin/env bash

set -euo pipefail

# Copies udev rules from the repo into /etc/udev/rules.d when they differ, and reapplies them
# to devices already plugged in, so a second run changes nothing and doesn't ask for sudo.
install_udev_rules() {
  local rule dest changed=0

  for rule in "$DOTFILES_DIR"/udev/*.rules; do
    dest="/etc/udev/rules.d/${rule##*/}"
    cmp -s "$rule" "$dest" && continue
    log_step "Installing udev rule ${rule##*/}"
    sudo install -m 644 "$rule" "$dest"
    changed=1
  done

  if [ "$changed" -eq 0 ]; then
    log_info "udev rules already installed"
    return
  fi
  sudo udevadm control --reload-rules
  sudo udevadm trigger --subsystem-match=hidraw
}
