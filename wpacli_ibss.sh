#!/bin/bash
if [ $# != 1 ] ; then
 echo "$0 <SSID>"
 exit
fi
$rmt wpa_cli -iwlan0 disconnect
$rmt wpa_cli -iwlan0 remove_network all
$rmt wpa_cli -iwlan0 add_network
$rmt wpa_cli -iwlan0 set_network 0 frequency 2412
$rmt wpa_cli -iwlan0 set_network 0 mode 1
if [ ! -n "$rmt" ] ; then
$rmt wpa_cli -iwlan0 set_network 0 ssid \"$1\"
else
$rmt wpa_cli -iwlan0 set_network 0 ssid '\"'$1'\"'
fi
$rmt wpa_cli -iwlan0 set_network 0 auth_alg OPEN
$rmt wpa_cli -iwlan0 set_network 0 key_mgmt NONE
$rmt wpa_cli -iwlan0 set_network 0 scan_ssid 1
$rmt wpa_cli -iwlan0 select_network 0
$rmt wpa_cli -iwlan0 enable_network 0
$rmt wpa_cli -iwlan0 status
fconfig wlan0 mtu 1532
iwconfig wlan0 enc off
modprobe batman-adv
batctl if add wlan0
ifconfig wlan0 up
ifconfig bat0 up
if [ -n "$(dmesg | grep "Notifying OTG driver")" ]; then
brctl addbr bridge-link
brctl addif bridge-link bat0
brctl addif bridge-link usb0
udhcpc -i bridge-link -S
else
udhcpc -i bat0 -S
fi
node /home/root/about_edison/beacon.js

