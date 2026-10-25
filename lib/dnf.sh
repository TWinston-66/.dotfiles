#!/usr/bin/env bash

set -euo pipefail

# Installs what a package list (one per line, # starts a comment) names and rpm doesn't
# already have, so a second run installs nothing and doesn't ask for sudo.
dnf_install() {
  local list="$1" pkg missing=()

  while IFS= read -r pkg || [ -n "$pkg" ]; do
    pkg="${pkg%%#*}"
    pkg="${pkg//[[:space:]]/}"
    [ -n "$pkg" ] || continue
    rpm -q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
  done <"$list"

  if [ "${#missing[@]}" -eq 0 ]; then
    log_info "Packages from $(basename "$list") already installed"
    return
  fi

  log_step "Installing ${missing[*]}"
  sudo dnf install -y "${missing[@]}"
}
