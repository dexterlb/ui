#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"

function fit_in_panel {
    mktemp -u | read temp_image
    convert -resize "${panel_width}x${panel_height}>" "${1}" "${temp_image}"
    convert -trim +repage "${temp_image}" "${2}"
    rm -f "${temp_image}"
}

function calculate_size {
    if [[ "${1}" =~ "\.(png|xpm|jpg)$" ]]; then
        identify "${1}" | read _ _ size _
        echo "${size}" | perl -pe 's/x/ /g' > "${1}.size"
    fi
}

rm -rf "${generated_dir}"
mkdir -p "${generated_dir}"
cd "${generated_dir}"

# generate wallpaper
convert "${wallpaper}" wallpaper.jpg

# bake panel background while emulating feh's --bg-fill option
convert -resize "${screen_width},${screen_height}^" \
        -gravity center -crop "${screen_width}x${screen_height}x0x0" +repage \
        -gravity NorthEast -crop "${panel_width}x${panel_height}+0+0" +repage \
        -blur 5x7 \
        -modulate 85,70,65 \
        -fill green \
        -tint 5 \
        wallpaper.jpg panel_background.xpm
convert -fill red -tint 20 panel_background.xpm panel_background_notification.xpm

fit_in_panel "${logo}" logo.xpm

for image in *; do
    calculate_size "${image}"
done
