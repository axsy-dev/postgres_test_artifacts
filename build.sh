#!/usr/bin/env bash

set -ex


source ./build_platform.sh

build_release() {
    build_platform "darwin" $1 $2
    docker_build_platform "linux-amd64" $1 $2
}

build_release "0a13f19" "9.6.6-1"