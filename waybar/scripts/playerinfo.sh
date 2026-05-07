#!/bin/bash

# Check if playerctl can find an active player
if playerctl status >/dev/null 2>&1; then
    # A player is active, grab the metadata
    info=$(playerctl metadata --format '{{artist}} - {{title}}')
    
    # Use jq to safely construct the JSON, escaping any quotes/special characters in $info
    jq -nc --arg info "$info" '{text: "         ", tooltip: $info}'
else
    # No player is active. Output static JSON safely.
    jq -nc '{text: "         ", tooltip: false}'
fi
