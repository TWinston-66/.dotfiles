#!/usr/bin/env bash

set -euo pipefail

# Installs what a package list (one per line, # starts a comment) names and nothing installed
# provides yet, so a second run installs nothing and doesn't ask for sudo. A package the repos
# don't have for this machine (torbrowser-launcher isn't built for aarch64, for Asahi) is
# reported and skipped rather than stopping the rest of the setup.
dnf_install() {
  local list="$1" pkg missing=() failed=()

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
  sudo dnf install -y --skip-unavailable "${missing[@]}"

  for pkg in "${missing[@]}"; do
    rpm -q --whatprovides "$pkg" >/dev/null 2>&1 || failed+=("$pkg")
  done
  if [ "${#failed[@]}" -gt 0 ]; then
    log_err "Couldn't install with dnf: ${failed[*]}"
  fi
}

# Removes what a package list names and is still installed, along with whatever dnf finds
# only they needed, so a second run removes nothing and doesn't ask for sudo.
dnf_remove() {
  local list="$1" pkg present=()

  while IFS= read -r pkg || [ -n "$pkg" ]; do
    pkg="${pkg%%#*}"
    pkg="${pkg//[[:space:]]/}"
    [ -n "$pkg" ] || continue
    rpm -q "$pkg" >/dev/null 2>&1 && present+=("$pkg")
  done <"$list"

  if [ "${#present[@]}" -eq 0 ]; then
    log_info "Packages from $(basename "$list") already removed"
    return
  fi

  log_step "Removing ${present[*]}"
  sudo dnf remove -y "${present[@]}"
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
