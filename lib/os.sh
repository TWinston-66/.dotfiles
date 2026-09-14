#!/usr/bin/env bash

set -euo pipefail

detect_os() {
  case "$(uname -s)" in
    Darwin) DOTFILES_OS="macos" ;;
    Linux)
      if [ ! -e /etc/NIXOS ]; then
        echo "Unsupported Linux distribution (NixOS only)" >&2
        exit 1
      fi
      DOTFILES_OS="nixos"
      ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac
  export DOTFILES_OS

  case "$(uname -m)" in
    arm64|aarch64|x86_64) ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
}

install_native_prereqs() {
  if ! xcode-select -p >/dev/null 2>&1; then
    log_step "Installing Xcode Command Line Tools"
    xcode-select --install
    log_info "Finish GUI installer, then re-run script."
    exit 1
  fi
}

require_commands() {
  local cmd missing=()

  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    log_err "Missing ${missing[*]}. On NixOS these come from lattice; rebuild it first."
    exit 1
  fi
}
