#!/bin/zsh

setopt null_glob

current_dir=$(readlink -f $(dirname "${0}"))

if [[ -n ${1} ]]; then
    target_dir=${1}
else
    target_dir=$(readlink -f ${current_dir}/..)
fi

function get_vars {
    set | sed 's/=.*//g' | while read name; do
        echo -n "${name}=${(P)name//\\0/}"
        echo -en '\0'
    done
}

function gen_config {
    echo "generate ${2} from ${1}"
    get_vars | "${current_dir}"/confplate.py -s "${1}" > "${2}"
}

function find_vars_and_gen_config {
    echo "prepare to generate ${2} from ${1}"

    (
        find_between "${target_dir}" "${1}" -type f -name vars.sh | while read vars_script; do
            echo "using ${vars_script}"
            source ${vars_script}
        done

        vars_scripts=("${2}".*.vars.sh(N))

        for vars_script in ${vars_scripts[@]}; do
            (
                echo "using ${vars_script}"
                source "${vars_script}"
                gen_config "${1}" "${vars_script%.vars.sh}"
            )
        done

        if [[ ${vars_scripts[#]} -eq 0 ]]; then
            gen_config "${1}" "${2}"
        fi
    )
}

function find_between {
    if [[ "${2}" == "${1}"* ]]; then
        find_between "${1}" "$(dirname "${2}")" "${@:3}"
        find "${2}" -mindepth 1 -maxdepth 1 "${@:3}"
    fi
}

find ${target_dir} -type f -name '*.cin' -print0 | while read -d$'\0' f; do
    find_vars_and_gen_config "${f}" "${f%.cin}"
done