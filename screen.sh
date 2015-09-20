#!/bin/zsh

xrandr | perl -ne 'print "$1\n" if m/primary ([\d]+x[\d]+)/;' | head -n1 \
       | read screen_size
if [[ -z "${screen_size}" ]]; then
    xrandr | perl -ne 'print "$1\n" if m/connected ([\d]+x[\d]+)/;' | head -n1 \
           | read screen_size
fi
echo "${screen_size}" | read -d'x' screen_width screen_height
