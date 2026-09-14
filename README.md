<p align="center">
  <img src=".github/assets/banner.svg" alt="dotfiles" width="100%">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS">
  <a href="https://github.com/TWinston-66/lattice"><img src="https://img.shields.io/badge/NixOS-5277C3?style=flat-square&logo=nixos&logoColor=white" alt="NixOS"></a>
  <a href="https://github.com/TWinston-66/.dotfiles/releases"><img src="https://img.shields.io/github/v/release/TWinston-66/.dotfiles?style=flat-square" alt="Latest release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=flat-square" alt="MIT license"></a>
</p>

My configs for macOS and NixOS, linked into `$HOME` with
[GNU Stow](https://www.gnu.org/software/stow/). Safe to re-run.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/TWinston-66/.dotfiles/main/bootstrap.sh | bash
```

This clones the repo to `~/.dotfiles` (override with `DOTFILES_DIR`) and runs
`dotfiles.sh`. Files it would replace are moved to `~/.dotfiles-backup/`.

On NixOS, build [lattice](https://github.com/TWinston-66/lattice) first. It
installs the packages and sets the login shell.

## What it does

| Step | macOS | NixOS |
| --- | :---: | :---: |
| Install packages from the `Brewfile`, plus Claude Code and pi | ✓ | lattice |
| Link configs with Stow | ✓ | ✓ |
| Install tmux plugins | ✓ | ✓ |
| Set zsh as the login shell | ✓ | lattice |
| Apply system defaults, display layout and Touch ID for `sudo` | ✓ | |

**Configs:** bat, btop, ghostty, git, gitmux, lazygit, nvim, sesh, ssh,
starship, tealdeer, tmux, zed and zsh. On macOS, the Rectangle config is copied
in rather than linked.

## Update

```sh
~/.dotfiles/dotfiles.sh
brew update && brew upgrade  # macOS
```

Bumping `VERSION` on `main` publishes a GitHub release.

## License

[MIT](LICENSE)
