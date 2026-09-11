#!/usr/bin/env bash

set -euo pipefail

detect_os() {
  case "$(uname -s)" in
    Darwin) DOTFILES_OS="macos" ;;
    Linux)  DOTFILES_OS="linux" ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac
  export DOTFILES_OS

  case "$(uname -m)" in
    arm64|aarch64|x86_64|amd64) ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac

  if [ "$DOTFILES_OS" = "linux" ]; then
    if command -v apt-get >/dev/null 2>&1; then
      DOTFILES_LINUX_FAMILY="debian"
    elif command -v pacman >/dev/null 2>&1; then
      DOTFILES_LINUX_FAMILY="arch"
    elif command -v dnf >/dev/null 2>&1; then
      DOTFILES_LINUX_FAMILY="fedora"
    else
      echo "Unknown Linux package manager (need apt, pacman, or dnf)" >&2
      exit 1
    fi
    export DOTFILES_LINUX_FAMILY
  fi
}

install_native_prereqs() {
  case "$DOTFILES_OS" in
    macos)
      if ! xcode-select -p >/dev/null 2>&1; then
        log_step "Installing Xcode Command Line Tools"
        xcode-select --install
        log_info "Finish GUI installer, then re-run script."
        exit 1
      fi
      ;;
    linux)
      case "$DOTFILES_LINUX_FAMILY" in
        debian)
          sudo apt-get update -y
          sudo apt-get install -y build-essential procps curl file git ca-certificates
          ;;
        arch)
          sudo pacman -Sy --needed --noconfirm base-devel procps-ng curl file git
          ;;
        fedora)
          sudo dnf install -y @development-tools
          sudo dnf install -y procps-ng curl file git ca-certificates
          ;;
      esac
      ;;
  esac
}
