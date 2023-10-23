#!/usr/bin/env bash

set -e

. scripts/func.sh

if [ ! -f files/p3/bzImage-rr -a ! -f files/p3/initrd-rr ]; then
  BR_VERSION="2023.02.x"
  POJETCNAME="rr"
  BASEPATH=buildroot
  WORKPATH=.buildroot
  CLEAN=0
  . scripts/buildroot.sh "${BR_VERSION}" "${POJETCNAME}" "${BASEPATH}" "${WORKPATH}" ${CLEAN}
  [ $? -ne 0 ] && exit 1
  if [ -f ".buildroot/output/images/bzImage" -a -f .buildroot/output/images/rootfs.cpio.xz ]; then
    cp .buildroot/output/images/bzImage file/p3/bzImage-rr
    cp .buildroot/output/images/rootfs.cpio.xz file/p3/initrd-rr
  else
    exit 1
  fi
fi

# Convert po2mo, Get extractor, LKM, addons and Modules
convertpo2mo "files/initrd/opt/rr/lang"
getExtractor "files/p3/extractor"
getLKMs "files/p3/lkms" true
getAddons "files/p3/addons" true
getModules "files/p3/modules" true


IMAGE_FILE="rr.img"
gzip -dc "files/grub.img.gz" >"${IMAGE_FILE}"
fdisk -l "${IMAGE_FILE}"

LOOPX=$(sudo losetup -f)
sudo losetup -P "${LOOPX}" "${IMAGE_FILE}"

echo "Mounting image file"
mkdir -p "/tmp/p1"
mkdir -p "/tmp/p3"
sudo mount ${LOOPX}p1 "/tmp/p1"
sudo mount ${LOOPX}p3 "/tmp/p3"

echo "Remake initrd"
repackInitrd "files/p3/initrd-rr" "files/initrd"

echo "Copying files"
sudo cp -Rf "files/p1/"* "/tmp/p1"
sudo cp -Rf "files/p3/"* "/tmp/p3"
sync

echo "Unmount image file"
sudo umount "/tmp/p1"
sudo umount "/tmp/p3"
rmdir "/tmp/p1"
rmdir "/tmp/p3"

sudo losetup --detach ${LOOPX}

