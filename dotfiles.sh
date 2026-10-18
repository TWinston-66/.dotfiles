#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

source "$DOTFILES_DIR/lib/log.sh"
source "$DOTFILES_DIR/lib/homebrew.sh"
source "$DOTFILES_DIR/lib/packages.sh"
source "$DOTFILES_DIR/lib/shell.sh"
source "$DOTFILES_DIR/lib/stow.sh"

main() {
    require_apple_silicon
    log_title "dotfiles"

    sudo_keepalive
    install_xcode_clt

    install_packages
    stow_packages

    install_tpm
    set_default_shell
    macos_setup

    log_title "Done"
    log_ok "Machine configured. Follow steps below."
    log_info "1. Open Tailscale from the menu bar and sign in"
}

require_apple_silicon() {
    if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
        echo "Unsupported platform: $(uname -s) $(uname -m) (Apple Silicon macOS only)" >&2
        exit 1
    fi
}

install_xcode_clt() {
    if ! xcode-select -p >/dev/null 2>&1; then
        log_step "Installing Xcode Command Line Tools"
        xcode-select --install
        log_info "Finish GUI installer, then re-run script."
        exit 1
    fi
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
  bash "$DOTFILES_DIR/lib/defaults.sh"

  log_step "Applying display arrangement"
  bash "$DOTFILES_DIR/lib/displays.sh"

  log_step "Setting up Touch ID for sudo"
  sudo -v
  bash "$DOTFILES_DIR/lib/touch-sudo.sh"
}

main "$@"
