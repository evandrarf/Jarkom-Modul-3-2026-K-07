#!/bin/bash
# /root/init.sh (geto)
if [ -f /root/interfaces ]; then
    cp /root/interfaces /etc/network/interfaces
fi
ip addr flush dev eth0 2>/dev/null
ip addr add 10.67.4.2/24 dev eth0 2>/dev/null
ip link set eth0 up 2>/dev/null
ip route replace default via 10.67.4.1 dev eth0 2>/dev/null
echo "nameserver 192.168.122.1" > /etc/resolv.conf
