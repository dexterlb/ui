#!/bin/zsh

setopt null_glob

ui_dir="$(dirname "${0}")"/ui
i3_dir="${ui_dir}"/i3
hostname="$(hostname)"

num_batteries=0
for f in /sys/class/power_supply/BAT*; do
    num_batteries=$((num_batteries + 1))
done

. "${ui_dir}"/visual.sh
