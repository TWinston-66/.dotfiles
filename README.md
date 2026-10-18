<p align="center">
  <img src=".github/assets/banner.svg" alt="dotfiles" width="100%">
</p>

<p align="center">
  <a href="https://www.apple.com/macos"><img src="https://img.shields.io/badge/macOS-Homebrew-F9E2AF?style=flat-square&labelColor=313244&logo=apple&logoColor=CDD6F4" alt="macOS with Homebrew"></a>
  <a href="https://www.gnu.org/software/stow/"><img src="https://img.shields.io/badge/linked%20with-GNU%20Stow-94E2D5?style=flat-square&labelColor=313244" alt="GNU Stow"></a>
  <a href="https://github.com/TWinston-66/.dotfiles/releases"><img src="https://img.shields.io/github/v/release/TWinston-66/.dotfiles?style=flat-square&color=A6E3A1&labelColor=313244" alt="Latest release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-CBA6F7?style=flat-square&labelColor=313244" alt="MIT license"></a>
</p>

<p align="center">
  <b>A Mac, set up in one command.</b><br>
  Ghostty, tmux, Neovim and zsh in Catppuccin Mocha, plus the packages and system settings around them.
</p>

## Why these dotfiles

- **One command per machine.** `bootstrap.sh` clones the repo and runs `dotfiles.sh`,
  which does the rest. It's safe to re-run.
- **Nothing gets lost.** Any file Stow would replace is moved to `~/.dotfiles-backup/`
  first, in a folder stamped with the date.
- **Edits apply live.** Configs are symlinked rather than copied, so a change takes
  effect without re-running anything.

The NixOS half used to live here too. It moved into the `home/` folder of
[lattice](https://github.com/TWinston-66/lattice) when this repo went macOS-only.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/TWinston-66/.dotfiles/main/bootstrap.sh | bash
```

This clones the repo to `~/.dotfiles` (override with `DOTFILES_DIR`) and runs
`dotfiles.sh`.

## What it does

1. Installs the Xcode Command Line Tools, Homebrew and the `Brewfile`, plus Claude Code and pi.
2. Links the configs with Stow.
3. Installs tmux's plugins.
4. Sets zsh as the login shell.
5. Applies system defaults, the display layout and Touch ID for `sudo`.

## Configs

bat, btop, ghostty, git, gitmux, lazygit, nvim, pi, sesh, ssh, starship, tealdeer, tmux,
zed and zsh, each a Stow package laid out like `$HOME`. Rectangle's config is copied in
rather than linked, since Rectangle imports and renames its file.

## Update

```sh
~/.dotfiles/dotfiles.sh       # re-link configs and re-run setup
brew update && brew upgrade   # packages
```

Bumping `VERSION` on `main` publishes a GitHub release.

## License

[MIT](LICENSE)
