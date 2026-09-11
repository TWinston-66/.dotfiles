#!/usr/bin/env bash

set -euo pipefail

login_shell() {
  local user
  user="$(id -un)"

  if [ "$DOTFILES_OS" = "macos" ]; then
    dscl . -read "/Users/$user" UserShell 2>/dev/null | awk '{print $2}'
  else
    getent passwd "$user" 2>/dev/null | cut -d: -f7
  fi
}

set_default_shell() {
  local zsh_path current
  zsh_path="$(command -v zsh)"

  current="$(login_shell || true)"
  [ -n "$current" ] || current="${SHELL:-}"

  if [ "$current" = "$zsh_path" ]; then
    log_info "zsh already the default shell"
    return
  fi

  log_step "Setting zsh as default shell"
  if ! grep -qx "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi
  sudo chsh -s "$zsh_path" "$(id -un)"
}
