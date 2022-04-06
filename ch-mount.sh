#!/bin/bash
# qemu-aarch64-static is from the host
sudo cp /usr/bin/qemu-arm-static usr/bin/
sudo cp /usr/bin/qemu-aarch64-static usr/bin/

# https://unix.stackexchange.com/questions/120827/recursive-umount-after-rbind-mount
# https://matsuu.hatenablog.com/entry/20101225/1293262061
# https://qiita.com/ngyuki/items/a9cff2ba3fceb97d18ec

function mnt() {
    MOUNT_POINT=$(readlink -f ${2})/
    echo "MOUNTING"
    sudo mount  --rbind /dev ${MOUNT_POINT}dev/
    sudo mount -t proc none ${MOUNT_POINT}proc
    sudo mount  --rbind /sys ${MOUNT_POINT}sys/
    sudo mount --make-rslave ${MOUNT_POINT}dev/
    sudo mount --make-rslave ${MOUNT_POINT}proc
    sudo mount --make-rslave ${MOUNT_POINT}sys

    LC_ALL=C LANG=C sudo chroot ${MOUNT_POINT}
}

function umnt() {
    MOUNT_POINT=$(readlink -f ${2})/
    echo "UNMOUNTING"
    sudo umount -R ${MOUNT_POINT}dev/
    sudo umount -R ${MOUNT_POINT}proc
    sudo umount -R ${MOUNT_POINT}sys
}

if [ "$1" == "-m" ] && [ -n "$2" ] && (cat /proc/mounts | grep ${2} >/dev/null) ; then
    echo $2 is mounted.
    echo $2 please unmount
    sudo chroot $2
    exit 1
fi

if [ "$1" == "-m" ] && [ -n "$2" ] ;
then
:
    mnt $1 $2
elif [ "$1" == "-u" ] && [ -n "$2" ];
then
:
    umnt $1 $2
else
    echo ""
    echo "Either 1'st, 2'nd or both parameters were missing"
    echo ""
    echo "1'st parameter can be one of these: -m(mount) OR -u(umount)"
    echo "2'nd parameter is the full path of rootfs directory(with trailing '/')"
    echo ""
    echo "For example: ch-mount -m /media/sdcard/"
    echo ""
    echo 1st parameter : ${1}
    echo 2nd parameter : ${2}
fi

