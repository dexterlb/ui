#!/bin/zsh
export XKB_DEFAULT_LAYOUT="us,bg"
export XKB_DEFAULT_OPTIONS="grp:sclk_toggle,grp:rctrl_toggle,grp_led:scroll,compose:ralt"
if [[ "$1" == "dvorak" ]]; then
    export XKB_DEFAULT_VARIANT="dvorak,dvorak_phonetic"
    setxkbmap \
        -layout "us,bg" \
        -variant "dvorak,dvorak_phonetic" \
        -option "XkbOptions" \
            "grp:sclk_toggle,grp:rctrl_toggle,grp_led:scroll,compose:ralt" ${@:2}
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
