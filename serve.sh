#!/bin/zsh

server='naboo.qtrp.org'
remote_path='/srv/http/rnd'
webroot='https://rnd.qtrp.org'

if [[ -n "${2}" ]]; then
    filename="${2}"
else
    filename="$(basename "${1}")"
fi

ssh "${server}" rm -rvf "${remote_path}"/"${filename}" || exit 1
scp -r "${1}" "${server}:${remote_path}"/"${filename}" || exit 1

address="${webroot}/${filename}"

echo -n "${address}" | xclip -sel clip
echo "${address} copied"
