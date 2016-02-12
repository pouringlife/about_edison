#!/bin/sh

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

mount /dev/mmcblk1p2 /mnt
cp -r /mnt/home/usr/src/linux-headers-3.10.17-yocto-standard /usr/src/
ln -s /usr/src/linux-headers-3.10.17-yocto-standard /lib/modules/$(uname -r)/build
git clone https://git.open-mesh.org/batman-adv.git /home/root/batman-adv
make --directory /home/root/batman-adv
make --directory /home/root/batman-adv install 

rm /lib/systemd/system/awst.service
echo -e "[Unit]\nDescription=awst\nAfter=rc-local.service \n[Service]\nType=simple\nRemainAfterExit=true\nExecStart=/home/root/init.sh\nRestart=always\nRestartSec=10s\nTimeout=20s \n[Install]\nWantedBy=multi-user.target" >> /lib/systemd/system/awst.service
chmod 777 /lib/systemd/system/awst.service
systemctl enable awst.service
rm /home/root/init.sh
echo -e "#!/bin/bash\nrfkill unblock bluetooth\nhciconfig hci0 up \nwpa_cli -i wlan0 disconnect\nifconfig wlan0 mtu 1532\niwconfig wlan0 enc off\niwconfig wlan0 mode Ad-hoc essid Edison_adhoc ap 02:12:34:56:78:9A channel 1\nmodprobe batman-adv\nbatctl if add wlan0\nifconfig wlan0 up\nifconfig bat0 up\ndet=$(dmesg | grep "Notifying OTG driver")\nif [ -n "$det" ]; then\nbrctl addbr bridge-link\nbrctl addif bridge-link bat0\nbrctl addif bridge-link usb0\nudhcpc -i bridge-link -S\nelse\nudhcpc -i bat0 -S\nfi" >> /home/root/init.sh
chmod 777 /home/root/init.sh