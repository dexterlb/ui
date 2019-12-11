#!/bin/bash

if [[ -z "${TERMINAL_THEME}" ]]; then
    echo "\$TERMINAL_THEME defaulting to 'dark'" >&2
    theme="dark"
else
    theme="${TERMINAL_THEME}"
fi
