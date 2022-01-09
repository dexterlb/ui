#!/bin/bash

set -euo pipefail

cdir="$(dirname "$(readlink -f "${0}")")"

function msg {
    echo "${@}" >&2
}

function die {
    msg "${@}"
    exit 1
}

function get_sources {
    pactl list short sources \
        | grep -v -F .monitor \
        | awk '{ print $1 }'
}

# mutes all connected mics
function mute_all {
    msg 'muting all sources'
    get_sources \
        | xargs -I@ pactl set-source-mute '@' 1
}

# unmutes the default mic
function unmute_default {
    msg 'unmuting default source'
    pactl set-source-mute $(pactl get-default-source) 0
}

# checks if all mics are muted
function all_muted {
    get_sources \
        | xargs -I@ pactl get-source-mute '@' \
        | grep -q 'no$' \
        || return 0
    return 1
}

# if any mic was unmuted, mutes all mics
# if all mics were muted, unmutes default mic
function restrictive_toggle {
    if all_muted; then
        msg 'all sources are muted'
        unmute_default
    else
        msg 'some sources are not muted'
        mute_all
    fi
}

# blocks forever and prints 'muted' when all mics are muted and 'unmuted' otherwise
function monitor {
    (
        echo start
        pactl subscribe | "${cdir}"/util_scripts/throttle.sh 0.5s
    ) | while read -d $'\n' line; do
        if all_muted; then
            echo off
        else
            echo on
        fi
    done | uniq
}

case "${1}" in
    mute_all)
        mute_all ;;

    unmute_default)
        unmute_default ;;

    restrictive_toggle)
        restrictive_toggle ;;

    all_muted)
        all_muted || exit 1 ;;

    monitor)
        monitor ;;

    *)
        msg "what?"
        die "for usage, read the source" ;;
esac
