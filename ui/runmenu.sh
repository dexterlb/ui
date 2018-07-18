#!/bin/zsh
cdir="$(dirname "$0")"
. "${cdir}/visual.sh"

rofi ${rofi_common[@]} -show "${1}"
