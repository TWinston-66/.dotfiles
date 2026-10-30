#!/usr/bin/env bash

set -euo pipefail

# Installs from Flathub what a list (one app ID per line, # starts a comment) names and
# isn't installed yet, so a second run installs nothing and doesn't ask for sudo.
# Apps are installed one at a time, and one that fails (Discord has no aarch64 build, for
# Asahi) is reported and skipped rather than stopping the rest of the setup.
flathub_install() {
  local list="$1" app missing=() failed=()

  while IFS= read -r app || [ -n "$app" ]; do
    app="${app%%#*}"
    app="${app//[[:space:]]/}"
    [ -n "$app" ] || continue
    flatpak info "$app" >/dev/null 2>&1 || missing+=("$app")
  done <"$list"

  if [ "${#missing[@]}" -eq 0 ]; then
    log_info "Apps from $(basename "$list") already installed"
    return
  fi

  # Fedora may have Flathub already, possibly filtered to a few apps; this adds it or lifts that.
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  sudo flatpak remote-modify --no-filter --enable flathub

  for app in "${missing[@]}"; do
    log_step "Installing $app"
    sudo flatpak install -y --noninteractive flathub "$app" || failed+=("$app")
  done

  if [ "${#failed[@]}" -gt 0 ]; then
    log_err "Couldn't install from Flathub: ${failed[*]}"
  fi
}
