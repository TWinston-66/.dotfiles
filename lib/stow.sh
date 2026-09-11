#!/usr/bin/env bash

set -euo pipefail

DOTFILES_STOW_PACKAGES=(git zsh zed ssh ghostty tealdeer tmux sesh gitmux starship nvim bat btop lazygit)

stow_packages() {
  log_step "Stowing dotfiles"

  local backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"
  local backed_up=0
  local pkg file rel target resolved

  for pkg in "${DOTFILES_STOW_PACKAGES[@]}"; do
    while IFS= read -r file; do
      rel="${file#"$DOTFILES_DIR/$pkg/"}"
      target="$HOME/$rel"

      if [ -e "$target" ] || [ -L "$target" ]; then
        resolved="$(realpath "$target" 2>/dev/null || true)"
        case "$resolved" in
          "$DOTFILES_DIR"/* | "$DOTFILES_DIR") continue ;;
        esac

        if [ -L "$target" ]; then
          log_info "Backing up foreign symlink $target -> $(readlink "$target")"
        else
          log_info "Backing up existing $target"
        fi
      else
        continue
      fi

      mkdir -p "$backup_dir/$(dirname "$rel")"
      mv "$target" "$backup_dir/$rel"
      backed_up=1
    done < <(find "$DOTFILES_DIR/$pkg" \( -type f -o -type l \))
  done

  if [ "$backed_up" -eq 1 ]; then
    log_info "Pre-existing dotfiles backed up to $backup_dir"
  fi

  stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "${DOTFILES_STOW_PACKAGES[@]}"
  log_ok "Dotfiles stowed"
}
