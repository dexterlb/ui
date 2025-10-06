#!/usr/bin/env bash

set -euo pipefail

function msg {
    echo "${@}" >&2
}

function die {
    msg "${@}"
    exit 1
}

if ! git diff-index --quiet --cached HEAD -- || ! git diff-files --quiet; then
    die "repo is dirty, refusing to continue"
fi

if ! git show-ref --quiet refs/heads/octo; then
    initial="$(git rev-list --max-parents=0 HEAD)"
    git checkout "${initial}"
    git checkout -b octo
fi

git switch octo
git reset --hard "${1}"

git merge "${@:2}"
