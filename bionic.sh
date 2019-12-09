#!/bin/sh
sudo apt-get install debootstrap libc6-dev-arm64-cross gcc-aarch64-linux-gnu qemu-aarch64 btrfs-tools -y
mkdir /bionic
dd if=/dev/zero of=bionic.img bs=1 count=0 seek=4000M
mkfs.btrfs bionic.img
chmod 777 bionic.img
mount -o loop bionic.img /bionic
debootstrap --arch=arm64 --foreign bionic /bionic
sudo mount -o bind /dev /bionic/dev && sudo mount -o bind /dev/pts /bionic/dev/pts && sudo mount -t sysfs sys /bionic/sys && sudo mount -t proc proc /bionic/proc
cp /usr/bin/qemu-aarch64-static /bionic/usr/bin
> /home/config.sh
cat <<+ >> /home/config.sh
#!/bin/sh
echo " Configurando debootstrap segunda fase"
sleep 3
/debootstrap/debootstrap --second-stage
export LANG=C
echo "deb http://ports.ubuntu.com/ bionic main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ports.ubuntu.com/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Europe/Berlin" > /etc/timezone
echo "bionic" >> /etc/hostname
echo "127.0.0.1 bionic localhost
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" >> /etc/hosts
echo "auto lo
iface lo inet loopback" >> /etc/network/interfaces
echo "/dev/mmcblk0p1 /	   ext4	    errors=remount-ro,noatime,nodiratime 0 1" >> /etc/fstab
echo "tmpfs    /tmp        tmpfs    nodev,nosuid,mode=1777 0 0" >> /etc/fstab
echo "tmpfs    /var/tmp    tmpfs    defaults    0 0" >> /etc/fstab	
cat <<END > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests "0";
END
apt-get update
echo "Reconfigurando parametros locales"
sleep 1
locale-gen es_ES.UTF-8
export LC_ALL="es_ES.UTF-8"
update-locale LC_ALL=es_ES.UTF-8 LANG=es_ES.UTF-8 LC_MESSAGES=POSIX
dpkg-reconfigure locales
dpkg-reconfigure -f noninteractive tzdata
apt-get upgrade -y
sudo apt-get install wireless-tools iw ubuntu-desktop -y
rm -f /var/lib/dpkg/info/udev.post*
rm -f /var/lib/dpkg/info/udev.pre*
apt-get -f install
apt-get clean
adduser bionic
addgroup bionic sudo
addgroup bionic adm
addgroup bionic users
+
chmod +x  /home/config.sh
sudo cp  /home/config.sh /bionic/home
chroot /bionic /usr/bin/qemu-aarch64-static /bin/sh -i ./home/config.sh
rm /home/config.sh
sudo umount /bionic/dev/pts
sleep 3
sync
sudo umount /bionic/dev
sleep 3
sync
sudo umount /bionic/proc
sleep 3
sync
sudo umount /bionic/sys
sleep 3
sync
umount /bionic
exit
