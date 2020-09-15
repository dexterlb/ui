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
    xhost local:boinc       # allow boinc user to use GPU


    "${cdir}/klayout.sh"    # keyboard layout settings
    # xcape -e 'Caps_Lock=Escape'
} &

{
    "${cdir}/detect_displays.sh"
} &

parcellite -n &>/dev/null &         # clipboard manager

picom --no-fading-openclose --glx-no-stencil \
    -b -C -G \
    --shadow-exclude 'bounding_shaped || !bounding_shaped' \
    --fade-exclude 'bounding_shaped || !bounding_shaped' \
    --focus-exclude 'bounding_shaped || !bounding_shaped' \
    --glx-no-stencil --vsync -o 0
