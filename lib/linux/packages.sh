#!/usr/bin/env bash

set -euo pipefail

install_linux_apps() {
    log_step "Installing Linux Apps"
    install_manager
    install_zed_linux
    install_toshy

    am_install helium           am -ia helium
    am_install ghostty          am -e pkgforge-dev/ghostty-appimage ghostty "download/v"
    am_install cryptomator      am -e cryptomator/cryptomator cryptomator
    am_install obsidian         am -e obsidianmd/obsidian-releases obsidian
    am_install draw.io          am -ia draw.io
    am_install telegram         am -ia telegram
    am_install tor-browser      am -ia tor-browser
    am_install transmission-gtk am -ia transmission-gtk
    am_install firefox          am -ia firefox
    am_install etcher           am -ia etcher
}

am_install() {
  local name="$1"; shift
  if command -v "$name" >/dev/null 2>&1; then
    log_info "$name already installed"
    return
  fi
  log_step "Installing $name"
  "$@" || true
  command -v "$name" >/dev/null 2>&1 || log_err "Failed to install $name — continuing"
}

install_manager() {
  if command -v am >/dev/null 2>&1; then
    log_info "AM already installed"
    return
  fi

  log_step "Installing AM"
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  curl -fsSL -o "$tmpdir/INSTALL" https://raw.githubusercontent.com/ivan-hc/AM/main/INSTALL
  chmod a+x "$tmpdir/INSTALL"
  sudo "$tmpdir/INSTALL"

  rm -rf "$tmpdir"
  trap - EXIT
}

install_zed_linux() {
  if command -v zed >/dev/null 2>&1; then
    log_info "Zed already installed"
    return
  fi
  log_step "Installing Zed"
  curl -fsSL https://zed.dev/install.sh | sh
}

install_toshy() {
    if [ -d "$HOME/.config/toshy" ]; then
        log_info "Toshy already installed"
        return
    fi
    log_step "Installing Toshy"
    local bootstrap
    bootstrap="$(curl -fsSL https://raw.githubusercontent.com/RedBearAK/toshy/main/scripts/bootstrap.sh)"
    sh -c "$bootstrap"
}

