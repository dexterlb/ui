#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"

export QT_STYLE_OVERRIDE='gtk2'
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

. "${cdir}/klayout.sh" default no_set    # keyboard layout settings

{
    systemctl --user stop redshift
    systemctl --user start redshift
} &

sway -c "${cdir}/i3/config.sway"
