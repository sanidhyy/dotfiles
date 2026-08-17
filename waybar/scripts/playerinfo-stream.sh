#!/usr/bin/env bash

# Continuous now-playing module for Waybar.
# Streams playerctl events instead of being re-exec'd on a timer.

set -uo pipefail

FMT='{{artist}} - {{title}}'
PARENT=$PPID

cleanup() { pkill -P $$ 2>/dev/null; }
trap cleanup EXIT
trap 'cleanup; exit 0' TERM INT

( trap - EXIT TERM INT
  while kill -0 "$PARENT" 2>/dev/null; do sleep 5; done
  kill "$$" 2>/dev/null ) &

emit() {
  local info="${1:-}"
  if [[ -n "$info" && "$info" != " - " ]]; then
    jq -nc --arg info "$info" '{text: "         ", tooltip: $info}'
  else
    jq -nc '{text: "         ", tooltip: false}'
  fi
}

# --follow terminates once the last player goes away, so keep reattaching.
while true; do
  emit "$(playerctl metadata --format "$FMT" 2>/dev/null)"

  while IFS= read -r line; do
    emit "$line"
  done < <(playerctl --follow metadata --format "$FMT" 2>/dev/null)

  sleep 2
done
