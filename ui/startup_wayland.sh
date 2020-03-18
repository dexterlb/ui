#!/bin/bash

# nothing here yet
cdir="$(dirname "$(readlink -f "${0}")")"

"${cdir}"/redshift_control.sh start
