#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
export DISPLAY_SERVER=X11
"${cdir}"/screenshot.sh "${@}"
