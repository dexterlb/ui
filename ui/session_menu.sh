#!/bin/bash
cdir="$(dirname "$0")"
. "${cdir}/visual.sh"

if [[ -n "${1}" ]]; then
    res="${1}"
else
    res=$(echo -e "lock\nsuspend\nrestart\nhalt\nquit\ncancel" \
        | rofi "${rofi_common[@]}" -dmenu -p "manage session")
fi

function killx {
    killall i3
}

function lock {
    physlock -m -p "$(echo 'Locked!' | cowsay -f stegosaurus)"
    "${cdir}"/redshift_control.sh start
}

case "${res}" in
    'restart')
        systemctl reboot & killx
        exit 0
        ;;
    'halt')
        systemctl poweroff & killx
        exit 0
        ;;
    'quit')
        killx
        exit 0
        ;;
    'suspend')
        systemctl suspend
        exit 0
        ;;
    'lock')
        "${cdir}"/lock_x.sh &
        exit 0
        ;;
    *)
        echo "wut?"
        ;;
esac
