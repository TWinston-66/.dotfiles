#!/usr/bin/env bash

set -euo pipefail

# Tools Fedora doesn't package, from their own installers. Each is installed only when
# missing; re-running its installer by hand updates it.

FEDORA_GO_TOOLS=(
  github.com/jesseduffield/lazygit
  github.com/jesseduffield/lazydocker
  github.com/joshmedeski/sesh/v2
  github.com/arl/gitmux
)

enable_copr() {
  local repo="$1"
  if [ -e "/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:${repo%/*}:${repo#*/}.repo" ]; then
    return
  fi
  log_step "Enabling COPR $repo"
  sudo dnf copr enable -y "$repo"
}

install_starship() {
  if command -v starship >/dev/null 2>&1 || [ -x "$HOME/.local/bin/starship" ]; then
    log_info "starship already installed"
    return
  fi
  log_step "Installing starship"
  # The installer ends with setup instructions for every shell; .zshrc already does that.
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin" >/dev/null
}

# Built with go install straight into ~/.local/bin, which .zshrc puts on PATH.
install_go_tools() {
  local module name
  mkdir -p "$HOME/.local/bin"
  for module in "${FEDORA_GO_TOOLS[@]}"; do
    name="${module%/v[0-9]*}"
    name="${name##*/}"
    if [ -x "$HOME/.local/bin/$name" ]; then
      log_info "$name already installed"
      continue
    fi
    run_step "Building $name" env GOBIN="$HOME/.local/bin" go install "$module@latest"
  done
}

install_zed() {
  if [ -x "$HOME/.local/bin/zed" ]; then
    log_info "Zed already installed"
    return
  fi
  log_step "Installing Zed"
  # Zed updates itself from here on; its installer's PATH advice is already in .zshrc.
  curl -fsSL https://zed.dev/install.sh | sh >/dev/null
}

# Icons in Zed's terminal, which falls back to this font (settings.json). Ghostty has its own.
install_nerd_symbols() {
  local dir="$HOME/.local/share/fonts/NerdFontsSymbolsOnly"
  if [ -f "$dir/SymbolsNerdFontMono-Regular.ttf" ]; then
    log_info "Symbols Nerd Font already installed"
    return
  fi
  log_step "Installing Symbols Nerd Font"
  mkdir -p "$dir"
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz |
    tar -xJ -C "$dir"
  fc-cache -f "$dir" >/dev/null
}
