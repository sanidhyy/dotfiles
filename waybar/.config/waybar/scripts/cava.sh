#! /bin/bash

# Render a small audio visualizer for Waybar using CAVA (with Catppuccin Mocha colors).
# Prints bar characters with Pango markup to stdout continuously.

config_file="/tmp/waybar_cava_config"

pkill -f "cava -p $config_file" 2>/dev/null || true

bar="▁▂▃▄▅▆▇█"

# Color palette (Catppuccin Mocha)
colors=("#94e2d5" "#89dceb" "#74c7ec" "#89b4fa" "#cba6f7" "#f5c2e7" "#eba0ac" "#f38ba8")
letters=("A" "B" "C" "D" "E" "F" "G" "H")

dict="s/;//g;"
dict_step1=""
dict_step2=""

for ((i=0; i<8; i++)); do
    dict_step1="${dict_step1}s/$i/${letters[$i]}/g;"
    dict_step2="${dict_step2}s/${letters[$i]}/<span foreground='${colors[$i]}'>${bar:$i:1}<\/span>/g;"
done

dict="${dict} ${dict_step1} ${dict_step2}"

echo "
[general]
bars = 8

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
" > $config_file

cava -p "$config_file" | sed -u "$dict"
