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
    detect_os
    log_title "dotfiles manager — $DOTFILES_OS"

    case "$DOTFILES_OS" in
      macos) setup_macos ;;
      nixos) setup_nixos ;;
    esac
}

setup_macos() {
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

# Packages and the login shell come from lattice, so this only links configs.
setup_nixos() {
    require_commands stow git tmux

    DOTFILES_STOW_PACKAGES+=(hypr ghostty-nixos waybar mako rofi satty swayosd gtk qt6ct applications zathura)
    stow_packages
    install_tpm

    log_title "Done"
    log_ok "Configs linked."
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
