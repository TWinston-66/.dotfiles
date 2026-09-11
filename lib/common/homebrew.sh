#!/usr/bin/env bash

set -euo pipefail

load_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  local candidate
  for candidate in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    /home/linuxbrew/.linuxbrew/bin/brew \
    "$HOME/.linuxbrew/bin/brew"
  do
    if [ -x "$candidate" ]; then
      eval "$("$candidate" shellenv)"
      return 0
    fi
  done

  return 1
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
