#! /bin/bash

# Render a small audio visualizer for Waybar using CAVA.
# Prints bar characters to stdout continuously.
# Dependencies: cava, sed.

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# creating "dictionary" to replace char with bar
for ((i=0; i<${#bar}; i++)); do
    dict="${dict}s/$i/${bar:$i:1}/g;"
done

# write cava config
config_file="/tmp/waybar_cava_config"
echo "
[general]
bars = 12

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
" > $config_file

cava -p "$config_file" | sed -u "$dict"
