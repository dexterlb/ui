#!/bin/zsh
cdir="$(dirname "$(readlink -f "$0")")"

image_dir="${cdir}/images"
generated_dir="${cdir}/images/generated"

wallpaper="${image_dir}/machinarium.jpg"
lock_image="${image_dir}/stars_wide.png"
logo="${image_dir}/logo.png"
icons_dir="${image_dir}/icons"

rofi_common=(-font 'Fira Code 12')

panel_height=24
panel_width="${screen_width}"

col_highlight2="#26a73c"
col_highlight="#467d50"
col_highlight_text="#ebac54"
col_highlight_text2="#efebe2"
col_main="#2b5f37"
col_inactive2="#484e50"
col_inactive="#333333"
col_inactive_text="#cccccc"
col_dull="#5f676a"
col_dull2="#292d2e"
col_dead="#222222"
col_urgent="#900000"
col_urgent_bg="#2f343a"
col_urgent_text="#ffffff"


col_bar_bg_solid="#5a4931"
col_bar_bg="#1f4d4280"
