#!/usr/bin/env bash
# privacy dots for Waybar 
# mic:  green, cam: orange

set -euo pipefail

# Dependencies: pipewire (pw-dump), jq, fuser
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
      [ .[] 
        | select(.type=="PipeWire:Interface:Node")
        | select((.info.props."media.class"=="Audio/Source" or .info.props."media.class"=="Audio/Source/Virtual"))
        | select((.info.state=="running") or (.state=="running"))
      ] | (if length>0 then 1 else 0 end)
    ' 2>/dev/null || echo 0
  )"

  cam="$(fuser -s /dev/video* 2>/dev/null && echo 1 || echo 0)"
fi

# Colors
green="#30D158"   # mic
orange="#FF9F0A"  # cam

# build text string
text=""
[[ $mic -eq 1 ]] && text+="<span foreground=\"$green\">●</span> "
[[ $cam -eq 1 ]] && text+="<span foreground=\"$orange\">●</span> "
text="${text% }"
tooltip="Mic: $([[ $mic -eq 1 ]] && echo on || echo off) | Cam: $([[ $cam -eq 1 ]] && echo on || echo off)"

classes="privacydot"
[[ $mic -eq 1 ]] && classes="$classes mic-on" || classes="$classes mic-off"
[[ $cam -eq 1 ]] && classes="$classes cam-on" || classes="$classes cam-off"

jq -c -n --arg text "$text" --arg tooltip "$tooltip" --arg class "$classes" \
  '{text:$text, tooltip:$tooltip, class:$class}'
