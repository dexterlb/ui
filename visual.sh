#!/bin/zsh
cdir="$(readlink -f "$(dirname "$0")")"
. "${cdir}/screen.sh"

image_dir="${cdir}/images"
generated_dir="${cdir}/images/generated"

wallpaper="${image_dir}/meat.jpg"
logo="${image_dir}/logo.png"
icons_dir="${image_dir}/icons"

rofi_common=(-font 'Droid Sans Mono 12')

panel_height=24
panel_width="${screen_width}"
