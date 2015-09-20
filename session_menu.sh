#!/bin/zsh
cdir="$(dirname "$0")"
. "${cdir}/visual.sh"

res=$(echo -e "lock\nsuspend\nrestart\nhalt\nquit\ncancel" \
    | rofi ${rofi_common[@]} -dmenu -p "manage session")

function killx {
    killall i3
}

case ${res} in
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
        physlock & { sleep 3 ; sudo systemctl suspend }
        exit 0
        ;;
    'lock')
        physlock
        exit 0
        ;;
    *)
        echo "wut?"
        ;;
esac
