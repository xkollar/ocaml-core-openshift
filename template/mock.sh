#!/usr/bin/env bash
# Script for mocking OpenShift environment for purposes of testing
# application locally

root_dir="${root_dir:-${PWD}/mock_dir/}"
OPENSHIFT_DATA_DIR="${root_dir}data/"; export OPENSHIFT_DATA_DIR
OPENSHIFT_REPO_DIR="${root_dir}repo/"; export OPENSHIFT_REPO_DIR
OPENSHIFT_OCAML_CORE_ADDRESS=127.0.0.1; export OPENSHIFT_OCAML_CORE_ADDRESS
OPENSHIFT_OCAML_CORE_PORT=8080; export OPENSHIFT_OCAML_CORE_PORT

mkdir -p "${OPENSHIFT_DATA_DIR}"
mkdir -p "${OPENSHIFT_REPO_DIR}"

rm -rf "${OPENSHIFT_REPO_DIR}resources"
cp -r resources "${OPENSHIFT_REPO_DIR}"

erb < server.conf.erb > "${OPENSHIFT_DATA_DIR}server.conf"

env

oasis setup \
&& make \
&& ./server.native "$@"
