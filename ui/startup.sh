#!/bin/bash
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"
# . "${cdir}/interfaces.sh"

{
    # X settings
    xsetroot -cursor_name left_ptr

    "${cdir}/set_wallpaper.sh"

    export QT_STYLE_OVERRIDE='gtk2'
    export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

    pkill unclutter ; ( unclutter &>/dev/null ) &   # autohide pointer
    xset b off              # speakerectomy
    xset s off              # no screensaver
    xset s noblank          # no screen blanking
    xset -dpms              # no power saving
    # xset m 3/1 0            # mouse acceleration and speed

    # subscribe to "lock screen" events
    pkill xss-lock ; ( xss-lock -l -- "${cdir}/lock_x_with_fd.sh" ) &


    "${cdir}/klayout.sh"    # keyboard layout settings
    # xcape -e 'Caps_Lock=Escape'
    "${cdir}"/mic_mute.sh mute_all
} &

{
    sleep 0.2
    "${cdir}/detect_displays.sh"
} &

parcellite -n &>/dev/null &         # clipboard manager

/usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &

picom -b
