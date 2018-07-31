#!/bin/zsh
if [[ "$1" == "dvorak" ]]; then
    setxkbmap \
        -layout "us,bg" \
        -variant "dvorak,dvorak_phonetic" \
        -option "XkbOptions" \
            "grp:sclk_toggle,grp:rctrl_toggle,grp_led:scroll,compose:ralt" ${@:2}
else
    setxkbmap \
        -layout "us,bg" \
        -variant ",phonetic" \
        -option "XkbOptions" \
            "grp:sclk_toggle,grp:rctrl_toggle,grp_led:scroll,compose:ralt" ${@:1}
fi
