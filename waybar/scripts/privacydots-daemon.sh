#!/usr/bin/env bash

set -euo pipefail

CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-privacydots.json"
ONE_SHOT_SCRIPT="${ONE_SHOT_SCRIPT:-$HOME/.config/waybar/scripts/privacydots.sh}"
WAYBAR_SIGNAL="${WAYBAR_SIGNAL:-9}"

write_now() {
  mkdir -p "$(dirname "$CACHE_FILE")"
  if [[ -x "$ONE_SHOT_SCRIPT" ]]; then
    "$ONE_SHOT_SCRIPT" >"$CACHE_FILE".tmp 2>/dev/null || true
    if [[ -s "$CACHE_FILE".tmp ]]; then
      mv -f "$CACHE_FILE".tmp "$CACHE_FILE"
      pkill -RTMIN+"$WAYBAR_SIGNAL" waybar >/dev/null 2>&1 || true
      return 0
    fi
  fi

  printf '%s\n' '{"text":"","tooltip":"Mic: unknown | Cam: unknown","class":"privacydot"}' >"$CACHE_FILE"
  pkill -RTMIN+"$WAYBAR_SIGNAL" waybar >/dev/null 2>&1 || true
}

cleanup() {
  rm -f "$CACHE_FILE".tmp >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

write_now

if ! command -v pw-cli >/dev/null 2>&1; then
  while true; do
    sleep 5
    write_now
  done
fi

pw-cli subscribe 2>/dev/null | while IFS= read -r _; do
  write_now
done

