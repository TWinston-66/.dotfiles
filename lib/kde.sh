#!/usr/bin/env bash

set -euo pipefail

# KDE apps rewrite their config files whole when saving, which would replace a stowed link,
# so their settings are written in place with kwriteconfig6, as defaults.sh does on macOS.

kde_setup() {
  log_step "Applying KDE settings"

  # Okular: Shift-click in a PDF built with synctex jumps to that line in Zed (inverse search;
  # forward search is tex-forward-search). Zed by full path, since Okular started from the
  # menu doesn't have ~/.local/bin on PATH.
  kwriteconfig6 --file okularpartrc --group "Core General" --key ExternalEditor Custom
  kwriteconfig6 --file okularpartrc --group "Core General" --key ExternalEditorCommand "$HOME/.local/bin/zed %f:%l"
}
