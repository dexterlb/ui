#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"

export QT_STYLE_OVERRIDE='gtk2'
export QT_QPA_PLATFORMTHEME="${QT_STYLE_OVERRIDE}"
export QT_QPA_PLATFORM=wayland-egl
export MOZ_ENABLE_WAYLAND=1
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

if [[ -z "${1}" || "${1}" == "local" ]]; then
    SWAY_CONFIG="${cdir}"/i3/config.sway
elif [[ "${1}" == "remote" ]]; then
    SWAY_CONFIG="${cdir}"/i3/config.sway_remote
    export WLR_RDP_TLS_CERT_PATH=~/.rdp_cert/tls.crt
    export WLR_RDP_TLS_KEY_PATH=~/.rdp_cert/tls.key
    export WLR_BACKENDS=rdp
else
    echo "unknown option: ${1}" >&2 ; exit 1
fi

. "${cdir}/klayout.sh" default no_set    # keyboard layout settings

{
    if which redshift &>/dev/null; then
        systemctl --user stop redshift
        systemctl --user start redshift
    fi
} &

sway -c "${SWAY_CONFIG}"
