#!/bin/bash
cdir="$(dirname "$(readlink -f "${0}")")"

if [[ -z "${1}" ]]; then
    echo "usage: ${0} (light|dark)" >&2
    exit 1
fi

export TERMINAL_THEME="${1}"
"${cdir}"/../config_generator/generate.sh "${cdir}"/../configs/config/alacritty
