#!/usr/bin/env bash

set -euo pipefail

load_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  [ -x /opt/homebrew/bin/brew ] || return 1
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_homebrew() {
  if load_homebrew; then
    log_info "Homebrew already installed"
    return
  fi

  log_step "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if ! load_homebrew; then
    log_err "Homebrew installed but brew was not found"
    exit 1
  fi
}

brew_bundle() {
  local brewfile="$1"
  log_step "Installing packages from $(basename "$brewfile")"
  brew bundle --file="$brewfile"
}
