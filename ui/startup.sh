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

picom_opts=(--no-fading-openclose --glx-no-stencil
    -b
    --shadow-exclude 'bounding_shaped || !bounding_shaped'
    --fade-exclude 'bounding_shaped || !bounding_shaped'
    --focus-exclude 'bounding_shaped || !bounding_shaped'
    --glx-no-stencil --vsync -o 0 -m 1
    --fade-in-step=1 --fade-out-step=1 --fade-delta=0
)

/usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &

picom "${picom_opts[@]}" || picom "${picom_opts[@]}" --no-vsync
