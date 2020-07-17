#!/bin/bash
cdir="$(dirname "$(readlink -f "$0")")"
. "${cdir}/visual.sh"

revert() {
    xset dpms 0 0 0
}
trap revert HUP INT TERM
xset +dpms dpms 5 5 5
i3lock -n -i "${lock_image}"
revert
