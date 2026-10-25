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
  # The installer won't create its bin dir, and on a fresh system nothing has yet.
  mkdir -p "$HOME/.local/bin"
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

CRITERION_VERSION=2.5.0

# Criterion, the C test library, from its prebuilt Linux release into /usr/local, where its
# pkg-config file expects it. It needs only glibc. Fedora's loader doesn't look in
# /usr/local/lib, so that is added. Installed again only when CRITERION_VERSION changes.
install_criterion() {
  local tmp

  if grep -qx "Version: $CRITERION_VERSION" /usr/local/lib/pkgconfig/criterion.pc 2>/dev/null; then
    log_info "Criterion already installed"
    return
  fi
  if [ "$(uname -m)" != x86_64 ]; then
    log_info "Criterion's release is x86_64 only; skipping it on $(uname -m)"
    return
  fi

  log_step "Installing Criterion $CRITERION_VERSION"
  tmp="$(mktemp -d)"
  curl -fsSL "https://github.com/Snaipe/Criterion/releases/download/v$CRITERION_VERSION/criterion-$CRITERION_VERSION-linux-x86_64.tar.xz" |
    tar -xJ -C "$tmp" --strip-components=1
  sudo mkdir -p /usr/local/include /usr/local/lib
  sudo cp -R "$tmp/include/." /usr/local/include/
  sudo cp -R "$tmp/lib/." /usr/local/lib/
  rm -rf "$tmp"

  echo /usr/local/lib | sudo tee /etc/ld.so.conf.d/usr-local.conf >/dev/null
  sudo ldconfig
}

CREDENTIALSD_VERSION=0.3.1
CREDENTIALSD_RPM_VERSION=0.3.1.0-1.1
CREDENTIALSD_XPI_VERSION=0.2.0
CREDENTIALSD_XPI_ID=credentialsd-helper@iinuwa.xyz

# credentialsd, passkeys and security keys for Firefox, from its GitHub release: the service,
# its UI and the native-messaging host as RPMs (dnf pulls in their Fedora dependencies), and
# the signed add-on, which a Firefox policy installs into every profile. Firefox reads
# /etc/firefox/policies in place of the policies it ships with, so those are carried over.
# Installed again only when the versions change.
install_credentialsd() {
  local base="https://github.com/linux-credentials/credentialsd/releases/download/v$CREDENTIALSD_VERSION"
  local arch xpi="/usr/local/share/credentialsd/credentialsd-helper-$CREDENTIALSD_XPI_VERSION.xpi"
  local policies=/etc/firefox/policies/policies.json shipped=/usr/lib64/firefox/distribution/policies.json
  local seed tmp

  arch="$(uname -m)"

  if rpm -q "credentialsd-${CREDENTIALSD_RPM_VERSION%-*}" "credentialsd-ui-${CREDENTIALSD_RPM_VERSION%-*}" \
    "credentialsd-webextension-${CREDENTIALSD_RPM_VERSION%-*}" >/dev/null 2>&1; then
    log_info "credentialsd already installed"
  else
    log_step "Installing credentialsd $CREDENTIALSD_VERSION"
    sudo dnf install -y \
      "$base/credentialsd-$CREDENTIALSD_RPM_VERSION.$arch.rpm" \
      "$base/credentialsd-ui-$CREDENTIALSD_RPM_VERSION.$arch.rpm" \
      "$base/credentialsd-webextension-$CREDENTIALSD_RPM_VERSION.noarch.rpm"
  fi

  if [ -f "$xpi" ] && jq -e --arg id "$CREDENTIALSD_XPI_ID" --arg url "file://$xpi" \
    '.policies.ExtensionSettings[$id].install_url == $url' "$policies" >/dev/null 2>&1; then
    log_info "credentialsd Firefox add-on already installed"
    return
  fi

  log_step "Installing credentialsd Firefox add-on $CREDENTIALSD_XPI_VERSION"
  sudo mkdir -p "${xpi%/*}" "${policies%/*}"
  sudo curl -fsSL -o "$xpi" "$base/$CREDENTIALSD_XPI_ID-$CREDENTIALSD_XPI_VERSION.xpi"

  if [ -f "$policies" ]; then
    seed="$policies"
  elif [ -f "$shipped" ]; then
    seed="$shipped"
  else
    seed=/dev/null
  fi
  tmp="$(mktemp)"
  jq -s --arg id "$CREDENTIALSD_XPI_ID" --arg url "file://$xpi" \
    '(.[0] // {}) | .policies.ExtensionSettings[$id] = {installation_mode: "force_installed", install_url: $url}' \
    "$seed" >"$tmp"
  sudo install -m 644 "$tmp" "$policies"
  rm -f "$tmp"
}
