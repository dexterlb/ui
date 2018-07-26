#!/bin/zsh
cdir="$(readlink -f "$(dirname "${0}")")"
. "${cdir}/visual.sh"

function shrink_to_panel {
    convert -resize "${panel_width}x${panel_height}>" "${1}" "${2}"
}

function fit_in_panel {
    mktemp -u | read temp_image
    shrink_to_panel "${1}" "${temp_image}"
    convert -trim +repage "${temp_image}" "${2}"
    rm -f "${temp_image}"
}


function calculate_size {
    if [[ "${1}" =~ "\.(png|xpm|jpg|xbm)$" ]]; then
        identify "${1}" | read _ _ size _
        echo "${size}" | perl -pe 's/x/ /g' > "${1}.size"
    fi
}

function overlay_all_positions {
    shrink_to_panel "${1}" "${3}"
    mktemp -u | read temp_image
    convert -resize "${panel_width}x${panel_height}>" "${1}" "${temp_image}"
    identify "${temp_image}" | read _ _ size _
    identify "${2}" | read _ _ target_size _
    echo "${target_size}" | read -d'x' target_width _

    mkdir -p "${3}.overlay"
    for position in {0..$((target_width - 1))}; do
        output="${3}.overlay/$(basename "${2}").${position}.xpm"
        echo -en "\r generating ${output}    "
        if [[ ! -f "${output}" ]]; then
            convert "${2}" -crop "${size}+${position}+0" +repage "${temp_image}" \
                    -flatten "${output}"
        fi
    done
    echo 'done'
    rm -f "${temp_image}"
}

if [[ "${1}" == '--force' ]]; then
    rm -rf "${generated_dir}"
fi

mkdir -p "${generated_dir}"
cd "${generated_dir}"

# generate wallpaper
convert "${wallpaper}" wallpaper.jpg

# bake panel background while emulating feh's --bg-fill option
convert -resize "${screen_width},${screen_height}^" \
        -gravity center -crop "${screen_width}x${screen_height}x0x0" +repage \
        -gravity NorthEast -crop "${panel_width}x${panel_height}+0+0" +repage \
        -blur 5x7 \
        -modulate 55,65,98 \
        -fill green \
        wallpaper.jpg panel_background.xpm
convert -fill red -tint 20 panel_background.xpm panel_background_notification.xpm

fit_in_panel "${logo}" logo.xpm

mkdir -p icons
for image in "${icons_dir}"/*.png; do
    image_name="$(basename "${image}")"
    overlay_all_positions "${image}" panel_background.xpm "icons/${image_name%.png}.xpm" &
    overlay_all_positions "${image}" panel_background_notification.xpm "icons/${image_name%.png}.xpm" &
done

wait

for image in * icons/*; do
    calculate_size "${image}"
done
