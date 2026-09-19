#!/usr/bin/env bash
# Privacy dots for Waybar (mic + camera indicators).
# Prints JSON for Waybar; returns empty when nothing is active.

set -euo pipefail

JQ_BIN="${JQ:-jq}"
PW_DUMP_CMD="${PW_DUMP:-pw-dump}"

mic=0
cam=0

# mic & camera
if command -v "$PW_DUMP_CMD" >/dev/null 2>&1 && command -v "$JQ_BIN" >/dev/null 2>&1; then
  dump="$($PW_DUMP_CMD 2>/dev/null || true)"

  mic="$(
    printf '%s' "$dump" \
    | $JQ_BIN -r '
      any(
        .[];
        select(.type=="PipeWire:Interface:Node")
        | select((.info.props."media.class"=="Audio/Source") or (.info.props."media.class"=="Audio/Source/Virtual"))
        | select((.info.state=="running") or (.state=="running"))
      )
      | if . then 1 else 0 end
    ' 2>/dev/null || echo 0
  )"

  if compgen -G "/dev/video*" >/dev/null; then
    cam="$(fuser -s /dev/video* 2>/dev/null && echo 1 || echo 0)"
  else
    cam=0
  fi
fi

# Colors
green="#a6e3a1"   # mic
orange="#fab387"  # cam

# build text string
text=""
[[ $mic -eq 1 ]] && text+="<span foreground=\"$green\" size=\"larger\">󰍬</span> "
[[ $cam -eq 1 ]] && text+="<span foreground=\"$orange\" size=\"larger\"></span> "
text="${text% }"
tooltip="Mic: $([[ $mic -eq 1 ]] && echo on || echo off) | Cam: $([[ $cam -eq 1 ]] && echo on || echo off)"

classes="privacydot"
[[ $mic -eq 1 ]] && classes="$classes mic-on" || classes="$classes mic-off"
[[ $cam -eq 1 ]] && classes="$classes cam-on" || classes="$classes cam-off"

jq -c -n --arg text "$text" --arg tooltip "$tooltip" --arg class "$classes" \
  '{text:$text, tooltip:$tooltip, class:$class}'
