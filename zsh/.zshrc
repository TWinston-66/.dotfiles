typeset -U path PATH

# lazygit falls back to ~/Library/Application Support on macOS unless this is set
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if [ -d /opt/homebrew/bin ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -d /home/linuxbrew/.linuxbrew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ -z "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
  tmux attach || tmux new -s main
  exit
fi

# Catppuccin Mocha
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#6c7086,label:#cdd6f4"

eval "$(fzf --zsh)"

if [ -f "$HOME/.ssh/id_ed25519" ]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" >/dev/null 2>&1
  elif command -v keychain >/dev/null 2>&1; then
    eval "$(keychain add --eval --quiet "$HOME/.ssh/id_ed25519")"
  fi
fi

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

if command -v brew >/dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
autoload -Uz compinit && compinit

eval "$(starship init zsh)"

eval "$(zoxide init zsh)"
if command -v brew >/dev/null 2>&1; then
  _brew_prefix="$(brew --prefix)"
  for _f in "$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
            "$_brew_prefix/opt/fzf/shell/key-bindings.zsh"; do
    [ -f "$_f" ] && source "$_f"
  done
  unset _brew_prefix _f
fi

export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer"

alias ls='eza --icons -a --group-directories-first'
alias ll='eza -la --icons --git --header --group-directories-first'
alias tree='eza --tree --icons --git-ignore'
alias cat='bat --style=plain --paging=never'
alias cd='z'
alias where='fd'
alias lookf='rg'
alias nv='nvim'
alias vim='nvim'
alias vi='nvim'

export EDITOR="nvim"

export PATH="$HOME/.local/bin:$PATH"

if [ -d "/Applications/calibre.app/Contents/MacOS" ]; then
  export PATH="/Applications/calibre.app/Contents/MacOS:$PATH"
fi
