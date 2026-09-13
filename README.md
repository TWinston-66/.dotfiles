# dotfiles

Keeps the setups of personal macOS machines in sync. Fully idempotent.

- [Homebrew](https://brew.sh)
- [GNU Stow](https://www.gnu.org/software/stow/) 

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