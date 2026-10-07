typeset -U path PATH

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if [ -d /opt/homebrew/bin ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -z "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
  tmux attach || tmux new -s main
  exit
fi

# The theme lattice-theme has picked (lattice's modules/nixos/theme.nix writes these on
# every theme switch and wallpaper pick). Each tool is pointed at its file rather than
# given the colours, so it follows without a new shell: fzf, bat and delta read theirs on
# every run, starship at every prompt, lazygit and btop at launch. None of these exist on
# macOS, which keeps the Catppuccin Mocha literals below and in each tool's own config.
_lattice="$HOME/.cache/lattice"

if [ -r "$_lattice/theme.fzf" ]; then
  export FZF_DEFAULT_OPTS_FILE="$_lattice/theme.fzf"
else
  export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#6c7086,label:#cdd6f4"
fi
[ -r "$_lattice/starship.toml" ] && export STARSHIP_CONFIG="$_lattice/starship.toml"
[ -r "$_lattice/theme.bat" ] && export BAT_CONFIG_PATH="$_lattice/theme.bat"
[ -r "$_lattice/theme.lazygit.yml" ] &&
  export LG_CONFIG_FILE="$XDG_CONFIG_HOME/lazygit/config.yml,$_lattice/theme.lazygit.yml"
# btop.conf names catppuccin_mocha, and --themes-dir is searched ahead of
# ~/.config/btop/themes, so the generated file of that name there wins.
[ -r "$_lattice/catppuccin_mocha.theme" ] && alias btop="btop --themes-dir $_lattice"

eval "$(fzf --zsh)"

if [[ "$OSTYPE" == darwin* && -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" >/dev/null 2>&1
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

# Where zsh plugins live: Homebrew on macOS, the system profile on NixOS
if command -v brew >/dev/null 2>&1; then
  _share="$(brew --prefix)/share"
else
  _share=/run/current-system/sw/share
fi
_zsh_as="$_share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$_zsh_as" ] && source "$_zsh_as"
unset _zsh_as

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

# macOS ships its own `open`; only alias it on Linux
if [[ "$OSTYPE" == linux* ]] && command -v xdg-open >/dev/null 2>&1; then
  alias open='xdg-open'
fi

# Zed's CLI is `zed` on macOS (the cask installs it) but `zeditor` on NixOS, which is the
# name nixpkgs gives the binary; alias it back so the same word opens the editor on both
if [[ "$OSTYPE" == linux* ]] && command -v zeditor >/dev/null 2>&1; then
  alias zed='zeditor'
fi

# A command that ran 5s or more says so when it finishes, as a desktop notification -- what
# Ghostty's notify-on-command-finish does on macOS. foot shows it only while its window is
# out of focus (desktop-notifications.inhibit-when-focused); from inside tmux the request
# goes out through passthrough, which tmux.conf allows. First in precmd, to see the
# command's own exit status before another hook replaces it.
if [[ "$OSTYPE" == linux* ]]; then
  zmodload zsh/datetime
  _lattice_cmd_start=0
  _lattice_notify_preexec() {
    _lattice_cmd_start=$EPOCHSECONDS
    _lattice_cmd=${1//[[:cntrl:]]/ }
  }
  _lattice_notify_precmd() {
    local st=$? elapsed osc e=$'\e'
    ((_lattice_cmd_start)) || return 0
    elapsed=$((EPOCHSECONDS - _lattice_cmd_start))
    _lattice_cmd_start=0
    ((elapsed >= 5)) || return 0
    osc="$e]777;notify;Command finished;${_lattice_cmd[1,80]} (${elapsed}s, exit $st)$e\\"
    [[ -n $TMUX ]] && osc="${e}Ptmux;${osc//$e/$e$e}$e\\"
    printf '%s' "$osc" >/dev/tty
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook preexec _lattice_notify_preexec
  precmd_functions=(_lattice_notify_precmd $precmd_functions)
fi

export EDITOR="nvim"

export PATH="$HOME/.local/bin:$PATH"

if [ -d "/Applications/calibre.app/Contents/MacOS" ]; then
  export PATH="/Applications/calibre.app/Contents/MacOS:$PATH"
fi

_zsh_hl="$_share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [ -f "$_zsh_hl" ]; then
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

  # The theme's own, over the Mocha above, and again at any prompt after it changes -- the
  # styles are read as each line is drawn, so a switch recolours shells already open.
  if [ -r "$_lattice/theme.zsh" ]; then
    zmodload -F zsh/stat b:zstat
    _lattice_zsh_mtime=0
    _lattice_zsh_reload() {
      local mtime
      mtime=$(zstat +mtime "$_lattice/theme.zsh" 2>/dev/null) || return
      if [[ $mtime != "$_lattice_zsh_mtime" ]]; then
        _lattice_zsh_mtime=$mtime
        source "$_lattice/theme.zsh"
      fi
    }
    _lattice_zsh_reload
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _lattice_zsh_reload
  fi

  source "$_zsh_hl"
fi
unset _zsh_hl _share
