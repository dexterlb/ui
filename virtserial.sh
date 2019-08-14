#!/bin/bash

dir="${1}"
if [[ -z "${dir}" ]]; then
    dir=/tmp/virtserial
fi

function cleanup {
    rm -rf "${dir}" || exit 1
}

trap cleanup EXIT
cleanup

mkdir "${dir}"  || exit 1

( socat -d -d pty,raw,echo=0 pty,raw,echo=0 &> "${dir}/.log" ) &

sleep 1

read a b < <(
    cat "${dir}/.log" \
        | head -n2 | grep -o 'PTY is /dev/pts/[0-9]*' | cut -d ' ' -f 3 \
        | tr '\n' ' '
)

ln -s "${a}" "${dir}/a"
ln -s "${b}" "${dir}/b"

echo "Created ${dir}/a and ${dir}/b."

wait
