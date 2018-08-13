#!/bin/zsh

cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"

feh --bg-fill "${wallpaper}"

