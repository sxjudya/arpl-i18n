#!/usr/bin/env bash
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

if [ $# -ne 5 ]; then
  echo $0 BR_VERSION POJETCNAME BASEPATH WORKPATH [CLEAN]
  exit -1
fi

BR_VERSION=${1}  # "2023.02.x"
POJETCNAME=${2}  # rr
BASEPATH=${3}
WORKPATH=${4}
CLEAN=${5:-0}

if [ -f "${WORKPATH}/Makefile" ]; then
  if [ ${CLEAN} -eq 1 ]; then
    echo "Cleaning buildroot"
    make BR2_EXTERNAL=./external -j$(nproc) clean
    [ $? -ne 0 ] && exit 1
  fi
else
  git clone --single-branch -b ${BR_VERSION} https://github.com/buildroot/buildroot.git "${WORKPATH}"
  [ ! -f "${WORKPATH}/Makefile" ] && exit 1
fi

echo "Copying files"
cp -Ru "${BASEPATH}/"* "${WORKPATH}/"
[ ! -f "${WORKPATH}/configs/${POJETCNAME}_defconfig" ] && exit 2

cd "${WORKPATH}"

echo "Generating default config"
make BR2_EXTERNAL=./external -j$(nproc) ${POJETCNAME}_defconfig
[ $? -ne 0 ] && exit 3

echo "Download sources if not cached"
make BR2_EXTERNAL=./external -j$(nproc) source
[ $? -ne 0 ] && exit 4

echo "Prepare buildroot for first make"
make BR2_EXTERNAL=./external -j$(nproc)
[ $? -ne 0 ] && exit 5
