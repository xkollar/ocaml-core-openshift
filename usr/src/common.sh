#!/usr/bin/env bash

source "${OPENSHIFT_CARTRIDGE_SDK_BASH}"

set -eu

declare logfile=$( readlink -f "${OPENSHIFT_LOG_DIR}/ocaml_core.log" )

function timestamp() {
    local timelimit=${1:-30}
    while true; do
        read -t "${timelimit}"
        local ret=$?
        timestamp="$( date +%FT%T )"
        test "${ret}" -eq 0 && echo -e "[${timestamp}] $REPLY" \
        || ( test "${ret}" -gt 128 && echo "<${timestamp}> *mark*" ) \
        || break
    done || true
}

function install_local_package() {
    local dir="${1}"
    ( cd "${dir}"
        eval $( opam config env )
        if [ -f _oasis ]; then
            oasis setup
        fi
        declare pkgname=$( sed -n 's/name:\s*"\?\([^"]*\)"\?/\1/p' opam | head -1 )
        if ! [ -d "${OPAMROOT}/${OCAMLVERSION}/packages.dev/${pkgname}" ]; then
            opam pin add "${pkgname}" . -y |& tee -a "${logfile}"
        fi
        if opam list -i server &>/dev/null; then
            opam upgrade "${pkgname}" -y |& tee -a "${logfile}"
        else
            opam install "${pkgname}" -y |& tee -a "${logfile}"
        fi
    )
}
