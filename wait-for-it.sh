#!/bin/bash
set -eux

declare -r HOST="localhost:80"

wait-for-url() {
    echo "Testing $1"
    timeout -s TERM 120 bash -c \
    'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' ${0})" != "301" ]];\
    do echo "Waiting for ${0}" && sleep 2;\
    done' ${1}
    echo "OK!"
}
wait-for-url http://${HOST}
