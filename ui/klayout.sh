#!/bin/zsh
export XKB_DEFAULT_LAYOUT="us,bg"
export XKB_DEFAULT_OPTIONS="grp:rctrl_toggle,grp_led:scroll,compose:ralt"

if [[ "$1" == "dvorak" ]]; then
    export XKB_DEFAULT_VARIANT="dvorak,dvorak_phonetic"
elif [[ "$1" == "bds" ]]; then
    export XKB_DEFAULT_VARIANT=","
else
    export XKB_DEFAULT_VARIANT=",phonetic"
fi

if [[ "${2}" != "no_set" ]]; then
    setxkbmap \
        -layout "${XKB_DEFAULT_LAYOUT}" \
        -variant "${XKB_DEFAULT_VARIANT}" \
        -option "${XKB_DEFAULT_OPTIONS}" \
            ${@:1}
fi
