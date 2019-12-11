#!/bin/zsh
cdir="$(dirname "$0")"
. "${cdir}/visual.sh"

if [[ -n "${1}" ]]; then
    screenshot_type="${1}"
else
    echo \
"full screenshot
window screenshot
region screenshot
cancel" | rofi ${rofi_common[@]} -dmenu -p "screenshot" \
        | read screenshot_type _
fi

case "${screenshot_type}" in
    full)
        option=
        ;;
    window)
        option=-u
        ;;
    region)
        option=-s
        ;;
    *)
        echo "wut?"
        exit 1
        ;;
esac

filename="/tmp/screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

scrot -d 0.1 ${option} "${filename}"

echo \
"leave it be in ${filename}
copy filename to clipboard
copy image to clipboard
serve it
delete it
cancel" | rofi ${rofi_common[@]} -dmenu -p "what to do with the screenshot" \
        | read action object _

case "${action}" in
    leave)
        ;;
    copy)
        case "${object}" in
            filename)
                echo -n "${filename}" | xclip -sel clip
                ;;
            image)
                cat "${filename}" | xclip -sel clip -t image/png
                ;;
            *)
                echo "copy whaaaaat?"
                exit 1
                ;;
        esac
        ;;
    serve)
        termite -e zsh -i -l -c "serve '${filename}' ; sleep 1"
        ;;
    delete)
        rm -f "${filename}"
        ;;
    *)
        echo "wut?"
        exit 1
        ;;
esac
