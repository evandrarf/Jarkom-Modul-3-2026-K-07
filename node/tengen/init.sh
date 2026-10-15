#!/bin/bash
# /root/init.sh (tengen)
# Script inisialisasi otomatis DHCP server tengen saat project GNS3 dibuka

# 1. Pulihkan konfigurasi antarmuka jaringan
if [ -f /root/interfaces ]; then
    cp /root/interfaces /etc/network/interfaces
fi
ip addr flush dev eth0 2>/dev/null
ip addr add 10.67.4.10/24 dev eth0 2>/dev/null
ip link set eth0 up 2>/dev/null
ip route replace default via 10.67.4.1 dev eth0 2>/dev/null

# 2. DNS resolver
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 3. Pulihkan dan jalankan DHCP Server
mkdir -p /etc/dhcp /etc/default /var/lib/dhcp
[ -f /root/dhcpd.conf ] && cp /root/dhcpd.conf /etc/dhcp/dhcpd.conf
[ -f /root/isc-dhcp-server ] && cp /root/isc-dhcp-server /etc/default/isc-dhcp-server
touch /var/lib/dhcp/dhcpd.leases

if command -v dhcpd >/dev/null 2>&1; then
    service isc-dhcp-server restart
fi

/root/soal-2.sh
/root/soal-4.sh
/root/soal-5.sh
/root/soal-6.sh