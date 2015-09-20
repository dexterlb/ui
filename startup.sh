#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"
# . "${cdir}/interfaces.sh"

{
    # X settings
    xsetroot -cursor_name left_ptr

    feh --bg-fill "${generated_dir}"/wallpaper.jpg

    export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
    # unclutter &             # autohide pointer
    xset b off              # speakerectomy
    xset s off              # no screensaver
    xset s noblank          # no screen blanking
    xset -dpms              # no power saving
    # xset m 3/1 0            # mouse acceleration and speed
    xhost local:boinc       # allow boinc user to use GPU

    "${cdir}/klayout.sh"    # keyboard layout settings

} &
    
rofi ${rofi_common[@]} -key-run Mod4+p -key-window Mod4+Tab &

{
    cd "${cdir}"/info
    ./info.py &> /tmp/info.py.log &
}

parcellite -n &>/dev/null &         # clipboard manager
