#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
export DISPLAY_SERVER=wayland
"${cdir}"/screenshot.sh "${@}"
