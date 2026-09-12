#!/usr/bin/env bash

set -uo pipefail

# Captured from `displayplacer list` on winston's machine (32" external + MacBook
# built-in). Persistent ids are tied to the specific displays connected at capture
# time — if a different external monitor is hooked up, or none at all, this will
# just fail and the rest of setup should continue.

if ! command -v displayplacer >/dev/null 2>&1; then
  echo "NOTE: displayplacer not installed — skipping display arrangement (see Brewfile)" >&2
  exit 0
fi

if ! displayplacer \
  "id:4469472E-8A13-4F26-8ACD-646138629427 res:3008x1692 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
  "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1512x982 hz:120 color_depth:8 enabled:true scaling:on origin:(-1512,635) degree:0"; then
  echo "NOTE: displayplacer couldn't apply the saved arrangement (displays not" >&2
  echo "      connected, or ids changed) — skipping. Run 'displayplacer list' to" >&2
  echo "      regenerate the command in lib/macos/displays.sh." >&2
fi
