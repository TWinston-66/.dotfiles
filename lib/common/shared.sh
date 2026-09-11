#!/usr/bin/env bash

set -euo pipefail

shared_packages() {
    install_homebrew
    brew_bundle "$DOTFILES_DIR/Brewfile"
    install_tailscale
    install_claude_code
    install_pi
}

install_tailscale() {
    if [ "$DOTFILES_OS" = "macos" ]; then
      log_info "Tailscale installed via cask"
      return
    fi

    if command -v tailscale >/dev/null 2>&1; then
      log_info "Tailscale already installed"
      return
    fi
    log_step "Installing Tailscale"
    curl -fsSL https://tailscale.com/install.sh | sh
}

install_claude_code() {
    if command -v claude >/dev/null 2>&1; then
      log_info "Claude Code already installed"
      return
    fi
    log_step "Installing Claude Code"
    curl -fsSL https://claude.ai/install.sh | bash
}

install_pi() {
    if command -v pi >/dev/null 2>&1; then
      log_info "pi.dev already installed"
      return
    fi
    log_step "Installing pi.dev"
    curl -fsSL https://pi.dev/install.sh | sh
}

install_tpm() {
    local tpm_dir="$HOME/.local/share/tmux/plugins/tpm"

    if [ -d "$tpm_dir" ]; then
      log_info "tpm already installed"
    else
      log_step "Installing tpm"
      git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    fi

    run_step "Installing tmux plugins" "$tpm_dir/bin/install_plugins"
}
