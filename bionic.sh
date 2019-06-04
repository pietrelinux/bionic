#!/bin/sh

mkdir /bionic
dd if=/dev/zero of=bionic.img bs=1 count=0 seek=4000M
mkfs.ext4 -b 4096 -F bionic.img
chmod 777 bionic.img
mount -o loop bionic.img /bionic
apt remove -y debootstrap

wget http://cz.archive.ubuntu.com/ubuntu/pool/main/d/debootstrap/debootstrap_1.0.95_all.deb
wget http://cz.archive.ubuntu.com/ubuntu/pool/main/u/ubuntu-keyring/ubuntu-keyring_2018.02.28_all.deb
dpkg -i *.deb

debootstrap --arch=arm64 --foreign bionic /bionic

sudo mount -o bind /dev /bionic/dev && sudo mount -o bind /dev/pts /bionic/dev/pts && sudo mount -t sysfs sys /bionic/sys && sudo mount -t proc proc /bionic/proc
export LANG=C
locale-gen es_ES.UTF-8
export LC_ALL="es_ES.UTF-8"
update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
echo "deb http://ports.ubuntu.com/ bionic main restricted universe multiverse" > /etc/apt/sources.list

echo "deb http://ports.ubuntu.com/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
apt update
apt-get upgrade -y
