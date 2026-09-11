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
source "$DOTFILES_DIR/lib/linux/packages.sh"

main() {
    detect_os
    log_title "dotfiles manager — $DOTFILES_OS ${DOTFILES_LINUX_FAMILY:-}"

    sudo_keepalive
    install_native_prereqs

    shared_packages
    if [ "$DOTFILES_OS" = "linux" ]; then
        install_linux_apps
    fi

    stow_packages

    install_tpm
    set_default_shell
    os_specific_setup

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

os_specific_setup() {
  case "$DOTFILES_OS" in
    macos)

      log_step "Applying macOS defaults"
      bash "$DOTFILES_DIR/lib/macos/defaults.sh"

      log_step "Setting up Touch ID for sudo"
      sudo -v
      bash "$DOTFILES_DIR/lib/macos/touch-sudo.sh"
      ;;
    linux) : ;;
  esac
}

main "$@"
