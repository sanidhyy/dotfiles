#!/usr/bin/env bash

# Continuous privacydots module for Waybar.
# Runs forever and prints a JSON line whenever mic/cam state changes.

set -euo pipefail

ONE_SHOT_SCRIPT="${ONE_SHOT_SCRIPT:-$HOME/.config/waybar/scripts/privacydots.sh}"
POLL_SEC="${POLL_SEC:-2}"

prev=""
while true; do
  curr="$("$ONE_SHOT_SCRIPT" 2>/dev/null || true)"

  # If the script fails or outputs nothing, keep the module visible but empty.
  if [[ -z "$curr" ]]; then
    curr='{"text":"","tooltip":"Mic: unknown | Cam: unknown","class":"privacydot"}'
  fi

  if [[ "$curr" != "$prev" ]]; then
    printf '%s\n' "$curr"
    prev="$curr"
  fi

  sleep "$POLL_SEC"
done
