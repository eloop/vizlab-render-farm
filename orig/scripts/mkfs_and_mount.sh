#!/bin/env bash

# args: mkfs_and_mount.sh <device> <part> <mountpoint>

device=$1
disk_partition=$2
mountpoint=$3

echo "device=$device"
echo "disk_partition=$disk_partition"
echo "mountpoint=$mountpoint"

if [ -n "$(sudo file -s $disk_partition | grep filesystem)" ]; then
    echo "Filesystem exists on $disk_partition, not making new filesystem"
else
    echo "No filesystem exists on $disk_partition"
    sudo parted -s $device mklabel gpt
    sudo parted -s -a optimal $device mkpart primary ext4 0% 100%
    sudo mkfs.ext4 $disk_partition
fi

if grep -q "$mountpoint" /etc/fstab; then
    echo $mountpoint is already in fstab.
else
    sudo sh -c "echo $disk_partition $mountpoint ext4     defaults 0 0 | tee -a /etc/fstab"
    echo Added $mountpoint to fstab.
fi

echo Mounting all in fstab.
sudo mount -a
