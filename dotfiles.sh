#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

source "$DOTFILES_DIR/lib/log.sh"
source "$DOTFILES_DIR/lib/dnf.sh"
source "$DOTFILES_DIR/lib/flatpak.sh"
source "$DOTFILES_DIR/lib/kde.sh"
source "$DOTFILES_DIR/lib/udev.sh"
source "$DOTFILES_DIR/lib/homebrew.sh"
source "$DOTFILES_DIR/lib/packages.sh"
source "$DOTFILES_DIR/lib/shell.sh"
source "$DOTFILES_DIR/lib/ssh.sh"
source "$DOTFILES_DIR/lib/stow.sh"
source "$DOTFILES_DIR/lib/upstream.sh"

main() {
    detect_os
    log_title "dotfiles"

    case "$DOTFILES_OS" in
    macos) setup_macos ;;
    fedora) setup_fedora ;;
    esac
}

# Apple Silicon macOS or Fedora, from uname and /etc/os-release (read in a subshell so its
# variables stay out of this one).
detect_os() {
    if [ "$(uname -s)" = Darwin ] && [ "$(uname -m)" = arm64 ]; then
        DOTFILES_OS=macos
    elif [ "$(uname -s)" = Linux ] && [ "$( (. /etc/os-release && echo "${ID:-}") 2>/dev/null)" = fedora ]; then
        DOTFILES_OS=fedora
    else
        echo "Unsupported platform: $(uname -s) $(uname -m) (Apple Silicon macOS or Fedora only)" >&2
        exit 1
    fi
    export DOTFILES_OS
}

setup_macos() {
    sudo_keepalive
    install_xcode_clt

    install_packages
    install_ssh_key
    stow_packages

    install_tpm
    set_default_shell
    macos_setup

    log_title "Done"
    log_ok "Machine configured. Follow steps below."
    log_info "1. Open Tailscale from the menu bar and sign in"
}

setup_fedora() {
    enable_copr atim/gping
    enable_copr scottames/ghostty
    dnf_install "$DOTFILES_DIR/packages/fedora.txt"
    dnf_remove "$DOTFILES_DIR/packages/fedora-remove.txt"
    enable_service tailscaled
    tailscale_setup
    install_udev_rules
    flathub_install "$DOTFILES_DIR/packages/flathub.txt"
    install_starship
    install_go_tools
    install_zed
    install_nerd_symbols
    install_gruvbox_icons
    install_claude_code
    install_pi
    install_criterion
    install_credentialsd
    install_librepods
    install_ssh_key
    stow_packages

    install_tpm
    set_default_shell
    kde_setup

    log_title "Done"
    log_ok "Machine configured. Follow steps below."
    log_info "1. Log out and back in for zsh to become your shell"
    log_info "2. Sign in to Tailscale: sudo tailscale up"
}

install_xcode_clt() {
    if ! xcode-select -p >/dev/null 2>&1; then
        log_step "Installing Xcode Command Line Tools"
        xcode-select --install
        log_info "Finish GUI installer, then re-run script."
        exit 1
    fi
}

# Routes other machines advertise (subnet routers), which Linux leaves off by default and
# macOS's app takes, and Tailscale's tray icon, started at login by the user unit the
# package ships. The tray runs as this user, so this user is made Tailscale's operator,
# which lets it connect and change settings without sudo. The routes and operator are
# saved in tailscaled's prefs, so they hold through the sign-in after.
tailscale_setup() {
  log_step "Setting up Tailscale"
  sudo tailscale set --accept-routes --operator="$USER"
  systemctl --user enable --now tailscale-systray
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
