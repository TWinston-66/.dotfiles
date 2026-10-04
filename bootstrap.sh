#!/usr/bin/env bash
# curl -fsSL https://raw.githubusercontent.com/TWinston-66/.dotfiles/main/bootstrap.sh | bash

set -euo pipefail

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/TWinston-66/.dotfiles.git}"
TARGET_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

if [ -d "$TARGET_DIR/.git" ]; then
  echo "==> dotfiles repo already present at $TARGET_DIR, pulling latest"
  git -C "$TARGET_DIR" pull --ff-only
else
  echo "==> cloning dotfiles to $TARGET_DIR"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

exec "$TARGET_DIR/dotfiles.sh" "$@"
