#!/bin/zsh

setopt null_glob

cdir="$(dirname "$(readlink -f "${0}")")"

ui_dir="${cdir}"/ui
i3_dir="${ui_dir}"/i3
hostname="$(hostname)"

num_batteries=0
for f in /sys/class/power_supply/BAT*; do
    num_batteries=$((num_batteries + 1))
done

. "${cdir}"/secrets.sh

. "${ui_dir}"/visual.sh
