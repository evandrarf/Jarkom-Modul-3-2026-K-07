#!/bin/sh
# /root/init.sh (kusakabe)
if [ -f /root/interfaces ]; then
    cp /root/interfaces /etc/network/interfaces
fi
hostname kusakabe 2>/dev/null
echo "kusakabe" > /etc/hostname 2>/dev/null
ip link set dev eth0 down 2>/dev/null
ip link set dev eth0 address 02:42:a2:f9:8e:00 2>/dev/null
ip link set dev eth0 up 2>/dev/null
killall udhcpc 2>/dev/null
ip addr flush dev eth0 2>/dev/null
udhcpc -i eth0 -x hostname:kusakabe
