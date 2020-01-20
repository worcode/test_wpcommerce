#!/usr/bin/env bash

set -e
set -p pipefail

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SSL_PATH="${SCRIPT_PATH}/../ssl"

function fail {
    printf 'fail => %s' "$1" >&2
    exit "${2-1}"
}

function createSelfCert {
    command -v openssl || fail "openssl is not found, please install and try again !"

    if ! [[ -d "${SSL_PATH}" ]]; then
        mkdir "${SSL_PATH}"
    fi;

    sudo openssl req -x509 -nodes -days 365 -subj "/C=TH/ST=BKK/O=Any co, ltd./CN=localhost" -addext "subjectAltName=DNS:localhost" -newkey rsa:2048 -keyout "${SSL_PATH}/localhost.key" -out "${SSL_PATH}/localhost.crt"
}

function createAsymmeticJwt {
    ssh-keygen -t rsa -b 4096 -m PEM -f "${SCRIPT_PATH}/../ssl/jwtRS256.key"
    openssl rsa -in "${SCRIPT_PATH}/../ssl/jwtRS256.key" -pubout -outform PEM -out "${SCRIPT_PATH}/../ssl/jwtRS256.key.pub"
}

function buildProxy {
    command -v docker || fail "docker is not found !"

    docker build -t wpapi-proxy:latest "${SCRIPT_PATH}/../nginx"
}

createSelfCert
createAsymmeticJwt
buildProxy
