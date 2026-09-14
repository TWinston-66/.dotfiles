# dotfiles

Keeps the setups of personal macOS machines in sync. Fully idempotent.

- [Homebrew](https://brew.sh)
- [GNU Stow](https://www.gnu.org/software/stow/) 

The same configs are shared with NixOS machines built from
[lattice](https://github.com/TWinston-66/lattice). There, lattice installs the
packages and sets the login shell, and `dotfiles.sh` only links configs and
installs tmux plugins.

## Usage

```bash
# bootstrap
curl -fsSL https://raw.githubusercontent.com/TWinston-66/dotfiles/main/bootstrap.sh | bash
```

```bash
# updating
./dotfiles.sh
brew update && brew upgrade
``` 