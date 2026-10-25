#!/usr/bin/env bash

set -euo pipefail

# Installs what a package list (one per line, # starts a comment) names and nothing installed
# provides yet, so a second run installs nothing and doesn't ask for sudo.
dnf_install() {
  local list="$1" pkg missing=()

  while IFS= read -r pkg || [ -n "$pkg" ]; do
    pkg="${pkg%%#*}"
    pkg="${pkg//[[:space:]]/}"
    [ -n "$pkg" ] || continue
    # By what packages provide, not their names: Fedora 44 has nodejs as nodejs22.
    rpm -q --whatprovides "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
  done <"$list"

  if [ "${#missing[@]}" -eq 0 ]; then
    log_info "Packages from $(basename "$list") already installed"
    return
  fi

  log_step "Installing ${missing[*]}"
  sudo dnf install -y "${missing[@]}"
}

enable_service() {
  local service="$1"
  if systemctl is-enabled --quiet "$service" 2>/dev/null; then
    log_info "$service already enabled"
    return
  fi
  log_step "Enabling $service"
  sudo systemctl enable --now "$service"
}
