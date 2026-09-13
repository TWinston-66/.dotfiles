#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

source "$DOTFILES_DIR/lib/os.sh"
source "$DOTFILES_DIR/lib/log.sh"
source "$DOTFILES_DIR/lib/common/homebrew.sh"
source "$DOTFILES_DIR/lib/common/shared.sh"
source "$DOTFILES_DIR/lib/common/shell.sh"
source "$DOTFILES_DIR/lib/stow.sh"

main() {
    require_macos
    log_title "dotfiles manager — macos"

    sudo_keepalive
    install_native_prereqs

    shared_packages

    stow_packages

    install_tpm
    set_default_shell
    macos_setup

    log_title "Done"
    log_ok "Machine configured. Follow steps below."
    log_info "1. run \`sudo tailscale up\`"
}

sudo_keepalive() {
  sudo -v
  while true; do
    sleep 120
    kill -0 "$$" 2>/dev/null || exit
    sudo -n true
  done 2>/dev/null &
}

macos_setup() {
  log_step "Applying macOS defaults"
  bash "$DOTFILES_DIR/lib/macos/defaults.sh"

  log_step "Applying display arrangement"
  bash "$DOTFILES_DIR/lib/macos/displays.sh"

  log_step "Setting up Touch ID for sudo"
  sudo -v
  bash "$DOTFILES_DIR/lib/macos/touch-sudo.sh"
}

main "$@"
