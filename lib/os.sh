#!/usr/bin/env bash

set -euo pipefail

detect_os() {
  case "$(uname -s)" in
    Darwin) DOTFILES_OS="macos" ;;
    *) echo "Unsupported OS: $(uname -s) (macOS only)" >&2; exit 1 ;;
  esac
  export DOTFILES_OS

  case "$(uname -m)" in
    arm64|x86_64) ;;
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
