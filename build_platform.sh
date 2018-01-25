#!/usr/bin/env bash

set -ex

build_postgres() {
    rm -rf ${PREFIX}/*
    pushd ${POSTGRES_DIR}
        ./configure --prefix=${PREFIX} \
            --with-uuid=e2fs
        make clean
        make -j 12
        make install
    popd
}

build_all_contrib() {
    pushd ${POSTGRES_CONTRIB_DIR}
        make clean
        make -j 12
        make install
    popd
}


build_extension() {
    local ext_dir=${EXT_DIR}/${1}
    [ -e ${ext_dir} ] || git clone --depth 1 ${2} ${ext_dir} && git -C ${ext_dir} checkout $3
    pushd ${ext_dir}
        rm -f wal2json.o
        rm -f wal2json.so
        PATH=${PREFIX}/bin/:${PATH}
        USE_PGXS=1 make
        USE_PGXS=1 make install
    popd
}
#
build_all_extensions() {
    build_extension wal2json https://github.com/eulerto/wal2json.git f68cb00
}

package() {
    pushd ${PREFIX}
        tar -cvzf ${RELEASE_TARGET} *
        shasum -a 256 ${RELEASE_TARGET} | cut -d " " -f 1  > ${RELEASE_TARGET_SHA}
    popd
}

build_platform() {
    PLATFORM=$1
    POSTGRES_RELEASE_HASH=$2
    POSTGRES_VERSION=$3

    BASE=${PWD}
    
    DIST_DIR=${BASE}/dist
    EXT_DIR=${DIST_DIR}/ext
    POSTGRES_DIR=${DIST_DIR}/postgres
    POSTGRES_CONTRIB_DIR=${POSTGRES_DIR}/contrib

    BUILD_DIR=${BASE}/build
    RELEASE_DIR=${BASE}/release

    PREFIX=${BUILD_DIR}/${PLATFORM}
    RELEASE_TARGET=${RELEASE_DIR}/postgres-${PLATFORM}-${POSTGRES_VERSION}.tar.gz
    RELEASE_TARGET_SHA=${RELEASE_DIR}/postgres-${PLATFORM}-${POSTGRES_VERSION}.sha256

    mkdir -p ${EXT_DIR} ${PREFIX} ${RELEASE_DIR}

    [ -e ${POSTGRES_DIR} ] || git -C ${DIST_DIR} clone https://github.com/postgres/postgres.git
    git -C ${POSTGRES_DIR} checkout ${POSTGRES_RELEASE_HASH}

    build_postgres
    build_all_contrib
    build_all_extensions
    package
}

docker_build_platform() {
    DOCKER_BUILD_SCRIPT=$(cat << EOF
apt-get update
apt-get install uuid-dev
cd build
source ./build_platform.sh && build_platform $1 $2 $3
EOF
)

    docker run --rm -v ${PWD}:/build gcc /bin/bash -c "${DOCKER_BUILD_SCRIPT}"
}


