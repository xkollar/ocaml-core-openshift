#!/usr/bin/env bash

source "${OPENSHIFT_CARTRIDGE_SDK_BASH}"

set -eu

declare logfile=$( readlink -f "${OPENSHIFT_LOG_DIR}/ocaml_core.log" )
