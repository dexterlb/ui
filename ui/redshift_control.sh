#!/bin/bash

function start_redshift {
    if pgrep '^sway$' &>/dev/null; then # wayland
        redshift -m wayland &> /dev/null &
    else
        redshift &>/dev/null &
    fi
}

function stop_redshift {
    i=0
    while pgrep '^redshift$' &>/dev/null; do
        killall redshift &>/dev/null
        sleep 0.1
        : $(( i++ ))
        if [[ ${i} -eq 5 ]]; then
            break
        fi
    done
    killall -9 redshift &>/dev/null
}

case "${1}" in
    start)
        stop_redshift
        start_redshift
        ;;
    stop)
        stop_redshift
        ;;
    *)
        echo 'what?' >&2
        exit 1
        ;;
esac

