#!/bin/bash

if [ "$(uname -r)" != "3.10.17-yocto-standard" ]; then

mkdir /home/root/boot-backup
cp -rp /boot/* /home/root/boot-backup/
umount /boot
mkfs.vfat -v -nboot -F16 /dev/mmcblk0p7
mount /boot
cp -rp /home/root/boot-backup/* /boot
rm -r /home/root/boot-backup

rm /etc/opkg/base-feeds.conf
echo src/gz all http://repo.opkg.net/edison/repo/all >> /etc/opkg/base-feeds.conf
echo src/gz edison http://repo.opkg.net/edison/repo/edison >> /etc/opkg/base-feeds.conf
echo src/gz core2-32 http://repo.opkg.net/edison/repo/core2-32 >> /etc/opkg/base-feeds.conf
opkg update
opkg install batctl git

if [ -f "/boot/bzImage-3.10.17-yocto-standard" ]; then
  mv /boot/vmlinuz /boot/vmlinuz.original.ww05
  mv /boot/bzImage-3.10.17-yocto-standard /boot/vmlinuz
else
  echo "bzImage-3.10.17-yocto-standard does not exist. Kernel does not change."
fi

opkg install kernel-module-aufs kernel-module-bcm-bt-lpm kernel-module-g-multi kernel-module-gspca-main kernel-module-iio-trig-sysfs kernel-module-libcomposite kernel-module-mac80211 kernel-module-test-nx kernel-module-u-serial kernel-module-usb-f-acm kernel-module-uvcvideo kernel-module-videobuf2-core kernel-module-videobuf2-memops kernel-module-videobuf2-vmalloc

opkg install --force-reinstall kernel-module-bcm4334x

fi

if [ -e /usr/src/linux-headers-3.10.17-yocto-standard ]; then
ar x /home/root/about_edison/linux-headers-3.10.17-yocto-standard_1.1_i386.deb data.tar.xz
mv data.tar.xz /home/root/about_edison/data.tar.xz
tar x -f /home/root/about/data.tar.xz
mv /home/root/about_edison/usr/src/linux-headers-3.10.17-yocto-standard /usr/src/
rm /lib/modules/3.10.17-yocto-standard/build
ln -s /usr/src/linux-headers-3.10.17-yocto-standard /lib/modules/3.10.17-yocto-standard/build
fi

git clone https://git.open-mesh.org/batman-adv.git /home/root/batman-adv

sed -e s/'$(shell uname -r)'/3.10.17-yocto-standard/g /home/root/batman-adv/Makefile > Makefile.tmp
mv Makefile.tmp /home/root/batman-adv/Makefile

make --directory /home/root/batman-adv
make --directory /home/root/batman-adv install

opkg install nodejs
npm install noble
npm install socket.io-client

sed -e s/edison_host_name/$(hostname)/g /home/root/about_edison/beacon.js > beacon.tmp
mv beacon.tmp /home/root/about_edison/beacon.js

mv /home/root/about_edison/awst.service /lib/systemd/system/awst.service
chmod 777 /lib/systemd/system/awst.service
systemctl enable awst.service
chmod 777 /home/root/about_edison/init.sh
