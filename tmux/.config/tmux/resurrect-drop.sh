#!/usr/bin/env bash
# Continuum saves every 15 minutes, so a window's own session open at the time would come
# back at the next start as a plain detached one. resurrect hands this hook the file it
# just wrote; the sessions set to die with their window (.zshrc) are taken out of it.
drop=$(tmux list-sessions -F '#{?#{==:#{destroy-unattached},on},#{session_name},}' | grep . || true)
[ -n "$drop" ] || exit 0
awk -F '\t' 'NR == FNR { d[$0]; next } !($2 in d)' \
    <(printf '%s\n' "$drop") "$1" >"$1.tmp" && mv "$1.tmp" "$1"
