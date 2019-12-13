#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"

export QT_STYLE_OVERRIDE='gtk2'
export QT_QPA_PLATFORM=wayland-egl
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

. "${cdir}/klayout.sh" default no_set    # keyboard layout settings

{
    if which redshift &>/dev/null; then
        systemctl --user stop redshift
        systemctl --user start redshift
    fi
} &

sway -c "${cdir}/i3/config.sway"
