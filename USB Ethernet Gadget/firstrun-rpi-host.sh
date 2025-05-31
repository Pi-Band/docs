#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_hostname raspberrypi-zero
else
   echo raspberrypi-zero >/etc/hostname
   sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\traspberrypi-zero/g" /etc/hosts
fi
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom enable_ssh
else
   systemctl enable ssh
fi
if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'pi' '$5$5oPEOU4FlB$4GZov3pzhDAOGp7PvmefPYjWfWofbNIp/PEweEGn7M8'
else
   echo "$FIRSTUSER:"'$5$5oPEOU4FlB$4GZov3pzhDAOGp7PvmefPYjWfWofbNIp/PEweEGn7M8' | chpasswd -e
   if [ "$FIRSTUSER" != "pi" ]; then
      usermod -l "pi" "$FIRSTUSER"
      usermod -m -d "/home/pi" "pi"
      groupmod -n "pi" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=pi/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/pi/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /pi /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_wlan 'Nekohaus' '8bf43149e7cf9dee6f7548e3f1b369a01b418a7b2cc9258b8547ecd5b296c5aa' 'GB'
else
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=GB
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	ssid="Nekohaus"
	psk=8bf43149e7cf9dee6f7548e3f1b369a01b418a7b2cc9258b8547ecd5b296c5aa
}

WPAEOF
   chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
   rfkill unblock wifi
   for filename in /var/lib/systemd/rfkill/*:wlan ; do
       echo 0 > $filename
   done
fi
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_keymap 'gb'
   /usr/lib/raspberrypi-sys-mods/imager_custom set_timezone 'Europe/London'
else
   rm -f /etc/localtime
   echo "Europe/London" >/etc/timezone
   dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="gb"
XKBVARIANT=""
XKBOPTIONS=""

KBEOF
   dpkg-reconfigure -f noninteractive keyboard-configuration
fi

# Configurations for USB Ethernet Gadget
# Source: https://forums.raspberrypi.com/viewtopic.php?t=376578&sid=f4a120510b092c81512e393bed2e1cf9#p2252557

# Remove the rule setting gadget devices to be unmanagend
cp /usr/lib/udev/rules.d/85-nm-unmanaged.rules /etc/udev/rules.d/85-nm-unmanaged.rules
sed 's/^[^#]*gadget/#\ &/' -i /etc/udev/rules.d/85-nm-unmanaged.rules

# Create a Network Manager connection file
CONNFILE=/etc/NetworkManager/system-connections/usb0-dhcp.nmconnection
UUID=$(uuid -v4)
cat <<- EOF >${CONNFILE}
	[connection]
	id=usb0-dhcp
	uuid=${UUID}
	type=ethernet
	interface-name=usb0
	autoconnect-priority=100
	autoconnect-retries=2
	[ethernet]
	[ipv4]
	method=auto
	[ipv6]
	addr-gen-mode=default
	method=auto
	[proxy]
	EOF

# NetworkManager will ignore nmconnection files with incorrect permissions so change them here
chmod 600 ${CONNFILE}

rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0
