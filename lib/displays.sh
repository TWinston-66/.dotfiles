#!/usr/bin/env bash

set -uo pipefail

# 32" 4K external (scaled to look like 2560x1440) as the main display, MacBook built-in
# to its left. Screens are found by type rather than by persistent id, since the id
# differs between two monitors of the same model and can change across reconnects.

if ! command -v displayplacer >/dev/null 2>&1; then
  echo "NOTE: displayplacer not installed — skipping display arrangement (see packages/Brewfile)" >&2
  exit 0
fi

_list="$(displayplacer list 2>/dev/null)"

# Persistent id of the first screen whose Type line matches $1
_screen_id() {
  awk -v type="$1" '
    /^Persistent screen id:/ { id = $4 }
    /^Type:/ && index($0, type) { print id; exit }
  ' <<<"$_list"
}

_external="$(_screen_id "32 inch external screen")"
_builtin="$(_screen_id "MacBook built in screen")"

if [ -z "$_external" ] || [ -z "$_builtin" ]; then
  echo "NOTE: 32\" external and built-in screens not both connected — skipping" >&2
  echo "      display arrangement." >&2
  exit 0
fi

if ! displayplacer >/dev/null 2>&1 \
  "id:$_external res:2560x1440 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
  "id:$_builtin res:1512x982 hz:120 color_depth:8 enabled:true scaling:on origin:(-1512,540) degree:0"; then
  echo "NOTE: displayplacer couldn't apply the saved arrangement — skipping. Run" >&2
  echo "      'displayplacer list' to check the modes in lib/displays.sh." >&2
fi
