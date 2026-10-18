typeset -U path PATH

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

eval "$(/opt/homebrew/bin/brew shellenv)"

# Every terminal window is tmux: the first takes the session named main, and a
# window opened while main is already on screen gets a session of its own, which dies with
# the window (and which tmux.conf leaves out of resurrect's saves). Starts main if the server
# is gone. Only with a terminal on stdin and stdout, so a shell that tools like Zed start
# without one to read the environment carries on past this instead of exiting.
if [ -z "$TMUX" ] && [ -t 0 ] && [ -t 1 ] && command -v tmux >/dev/null 2>&1; then
  case $(tmux display -p -t '=main:' '#{session_attached}' 2>/dev/null) in
    0) tmux attach -t '=main' ;;
    "") tmux new -A -s main ;;
    *) tmux new \; set destroy-unattached on ;;
  esac
  exit
fi

if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
  ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" >/dev/null 2>&1
fi

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_FCNTL_LOCK

export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer"
export EDITOR="zed --wait"
export PATH="$HOME/.local/bin:$PATH"

if [ -d "/Applications/calibre.app/Contents/MacOS" ]; then
  export PATH="/Applications/calibre.app/Contents/MacOS:$PATH"
fi

alias ls='eza --icons -a --group-directories-first'
alias ll='eza -la --icons --git --header --group-directories-first'
alias tree='eza --tree --icons --git-ignore'
alias cat='bat --style=plain --paging=never'
alias cd='z'
alias where='fd'
alias lookf='rg'

# Gruvbox Material with the blue accent, for fzf here and syntax highlighting below.
export FZF_DEFAULT_OPTS=" \
--color=bg+:#32302f,bg:#282828,spinner:#dea473,hl:#ea6962 \
--color=fg:#d4be98,header:#ea6962,info:#d3869b,pointer:#dea473 \
--color=marker:#a89a9f,fg+:#d4be98,prompt:#d3869b,hl+:#ea6962 \
--color=selected-bg:#45403d \
--color=border:#7c6f64,label:#d4be98"

_share="$HOMEBREW_PREFIX/share"
FPATH="$_share/zsh/site-functions:${FPATH}"
autoload -Uz compinit && compinit

eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

source "$_share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# A command that ran 5s or more says so when it finishes, as a desktop notification. From
# inside tmux the request goes out through passthrough, which tmux.conf allows. First in
# precmd, to see the command's own exit status before another hook replaces it.
zmodload zsh/datetime
autoload -Uz add-zsh-hook
_notify_cmd_start=0
_notify_notify_preexec() {
  _notify_cmd_start=$EPOCHSECONDS
  _notify_cmd=${1//[[:cntrl:]]/ }
}
_notify_notify_precmd() {
  local st=$? elapsed osc e=$'\e'
  ((_notify_cmd_start)) || return 0
  elapsed=$((EPOCHSECONDS - _notify_cmd_start))
  _notify_cmd_start=0
  ((elapsed >= 5)) || return 0
  osc="$e]777;notify;Command finished;${_notify_cmd[1,80]} (${elapsed}s, exit $st)$e\\"
  [[ -n $TMUX ]] && osc="${e}Ptmux;${osc//$e/$e$e}$e\\"
  printf '%s' "$osc" >/dev/tty
}
add-zsh-hook preexec _notify_notify_preexec
precmd_functions=(_notify_notify_precmd $precmd_functions)

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#d4be98'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ea6962,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#d3869b'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#a9b665'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a9b665'
ZSH_HIGHLIGHT_STYLES[function]='fg=#a9b665'
ZSH_HIGHLIGHT_STYLES[command]='fg=#a9b665'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a9b665,italic'
ZSH_HIGHLIGHT_STYLES[path]='fg=#d4be98,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#7daea3'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#d8a657'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#d8a657'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#7c6f64,italic'
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#ea6962'
source "$_share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unset _share
