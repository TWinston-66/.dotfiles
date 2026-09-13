#!/usr/bin/env bash

set -euo pipefail

require_macos() {
  if [ "$(uname -s)" != "Darwin" ]; then
    echo "Unsupported OS: $(uname -s) (macOS only)" >&2
    exit 1
  fi

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
