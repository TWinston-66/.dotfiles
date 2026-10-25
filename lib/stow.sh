#!/usr/bin/env bash

set -euo pipefail

DOTFILES_STOW_PACKAGES=(git zsh zed ssh tealdeer sesh starship bat btop lazygit pi ghostty tmux gitmux)

stow_packages() {
    log_step "Stowing dotfiles"

    local backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"
    local backed_up=0
    local pkg file rel target resolved
    # Plus the package of files that differ by OS, named after it (macos, fedora).
    local packages=("${DOTFILES_STOW_PACKAGES[@]}" "$DOTFILES_OS")

    for pkg in "${packages[@]}"; do
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

    mkdir -p -m 700 "$HOME/.ssh"

    # --no-folding links each file rather than whole directories, so what apps write next to
    # their config stays out of the repo, and the OS package can add a file to a directory
    # another package also has. The shared packages go first: that turns whole-directory links
    # left by earlier runs into real directories, which stow can't do while adding the OS package.
    stow --dir="$DOTFILES_DIR" --target="$HOME" --no-folding --restow "${DOTFILES_STOW_PACKAGES[@]}"
    stow --dir="$DOTFILES_DIR" --target="$HOME" --no-folding --restow "$DOTFILES_OS"
    log_ok "Dotfiles stowed"
}
