#!/bin/bash
rfkill unblock bluetooth
hciconfig hci0 up
exec /home/root/about_edison/wpacli_ibss.sh Edison
