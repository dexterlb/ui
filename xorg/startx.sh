# load from your bash or zsh profile
cdir="$(dirname "$(readlink -f "${0}")")"

function start_x {
    # get the current TTY. We'll tell X to run on the same TTY to avoid problems.
    TTY=$(tty)
    TTY=${TTY#/dev/}
    vt=$(printf 'vt%02d' "${TTY#tty}")

    if [ -z ${xinitrc} ]; then
        xinitrc="$HOME/.xinitrc"
    fi

    echo "starting X with parameters: $@"  | ts
    startx "$xinitrc" "${@}" -- "$vt" 2>&1 | ts | tee /tmp/x_out
    # bug in X: redirecting stderr crashes it ^^^

    clear
    echo "X has exited. Output has been saved to /tmp/x_out." | ts
    echo "Press enter to relog."
    read enter
    exit
}

function xinteractive {
    # display a menu if no argument is given, otherwise assume choice from argument
    echo -en "\n"

    if [[ -z "$1" ]]; then
        echo -n "Enter choice ([i] i3, [f] fluxbox, [s] sway, [r] restart, [h] halt, [c] console): "
        read c
    else
        c="$1"
    fi

    echo -en "\n"

    case $c[1] in
        i) start_x i3 ;;
        f) start_x fluxbox ;;
        s) "${cdir}"/../ui/start_wayland.sh ;;

        r) systemctl reboot ;;
        h) systemctl poweroff ;;
        c) return ;;
    esac

    exit
}

# start X if we're on tty1
function xauto {
    if [[ -n ${1} ]]; then
        export xinitrc=${1}
    fi
    if [[ -z $DISPLAY ]] && [[ $(tty) =~ "/dev/tty[1-9]" ]]; then
        if [[ $(tty) = "/dev/tty1" ]] && [[ ! -f ~/x_noauto ]]; then
            xinteractive s
        else
            xinteractive
        fi
    fi
}
