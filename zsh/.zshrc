typeset -U path PATH

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

if command -v brew >/dev/null 2>&1; then
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

  typeset -gA ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8,bold'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6e3a1'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6e3a1'
  ZSH_HIGHLIGHT_STYLES[function]='fg=#a6e3a1'
  ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=#89b4fa'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f9e2af'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f9e2af'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086,italic'
  ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#f38ba8'

  _zsh_hl="$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [ -f "$_zsh_hl" ] && source "$_zsh_hl"
  unset _zsh_hl
fi
