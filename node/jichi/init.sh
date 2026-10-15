#!/bin/bash
# /root/init.sh (jichi)
# Script inisialisasi otomatis router jichi saat project GNS3 dibuka

# 1. Pulihkan konfigurasi antarmuka jaringan
if [ -f /root/interfaces ]; then
    cp /root/interfaces /etc/network/interfaces
fi
ip link set eth0 up 2>/dev/null
dhclient -r eth0 2>/dev/null; dhclient eth0 2>/dev/null || udhcpc -i eth0 2>/dev/null

ip addr flush dev eth1 2>/dev/null; ip addr add 10.67.1.1/24 dev eth1 2>/dev/null; ip link set eth1 up 2>/dev/null
ip addr flush dev eth2 2>/dev/null; ip addr add 10.67.2.1/24 dev eth2 2>/dev/null; ip link set eth2 up 2>/dev/null
ip addr flush dev eth3 2>/dev/null; ip addr add 10.67.3.1/24 dev eth3 2>/dev/null; ip link set eth3 up 2>/dev/null
ip addr flush dev eth4 2>/dev/null; ip addr add 10.67.4.1/24 dev eth4 2>/dev/null; ip link set eth4 up 2>/dev/null

# 2. DNS resolver ke gateway internet
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 3. Aktifkan IPv4 packet forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# 4. Konfigurasi Source NAT (MASQUERADE)
command -v iptables >/dev/null || { apt update && apt install -y iptables; }
iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# 5. Pulihkan dan jalankan DHCP Relay
if [ -f /root/isc-dhcp-relay ]; then
    cp /root/isc-dhcp-relay /etc/default/isc-dhcp-relay
fi

if command -v dhcrelay >/dev/null 2>&1; then
    service isc-dhcp-relay restart
fi

/root/soal-3.sh