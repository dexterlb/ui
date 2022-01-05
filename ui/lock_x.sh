#!/bin/bash
cdir="$(dirname "$(readlink -f "$0")")"
. "${cdir}/visual.sh"

revert() {
    xset dpms 0 0 0
}
trap revert HUP INT TERM

if [[ -z "${SUSPENDING}" ]]; then
    # if simply locking and not suspending, blank screen after 5 seconds
    xset +dpms dpms 5 5 5
fi
i3lock -n -i "${lock_image}"
revert
