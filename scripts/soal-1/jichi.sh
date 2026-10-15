#!/bin/bash
# scripts/soal-1/jichi.sh
# Konfigurasi Interface, IPv4 Forwarding, dan Source NAT pada router jichi

# 1. Tulis konfigurasi interfaces
cat << 'EOF' > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 10.67.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.67.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.67.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 10.67.4.1
    netmask 255.255.255.0
EOF

# Backup ke /root/interfaces
cp /etc/network/interfaces /root/interfaces

# 2. Terapkan konfigurasi antarmuka langsung ke kernel
ip link set eth0 up 2>/dev/null
dhclient -r eth0 2>/dev/null; dhclient eth0 2>/dev/null || udhcpc -i eth0 2>/dev/null

ip addr flush dev eth1 2>/dev/null; ip addr add 10.67.1.1/24 dev eth1 2>/dev/null; ip link set eth1 up 2>/dev/null
ip addr flush dev eth2 2>/dev/null; ip addr add 10.67.2.1/24 dev eth2 2>/dev/null; ip link set eth2 up 2>/dev/null
ip addr flush dev eth3 2>/dev/null; ip addr add 10.67.3.1/24 dev eth3 2>/dev/null; ip link set eth3 up 2>/dev/null
ip addr flush dev eth4 2>/dev/null; ip addr add 10.67.4.1/24 dev eth4 2>/dev/null; ip link set eth4 up 2>/dev/null

# 3. DNS resolver ke gateway internet
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 4. Aktifkan IPv4 Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# 5. Konfigurasi Source NAT (MASQUERADE)
command -v iptables >/dev/null || { apt update && apt install -y iptables; }
iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# 6. Buat file /root/init.sh yang lengkap dan tangguh untuk pemulihan otomatis
cat << 'EOF' > /root/init.sh
#!/bin/bash
# /root/init.sh (jichi)
# 1. Pulihkan interfaces
if [ -f /root/interfaces ]; then
    cp /root/interfaces /etc/network/interfaces
fi
ip link set eth0 up 2>/dev/null
dhclient -r eth0 2>/dev/null; dhclient eth0 2>/dev/null || udhcpc -i eth0 2>/dev/null

ip addr flush dev eth1 2>/dev/null; ip addr add 10.67.1.1/24 dev eth1 2>/dev/null; ip link set eth1 up 2>/dev/null
ip addr flush dev eth2 2>/dev/null; ip addr add 10.67.2.1/24 dev eth2 2>/dev/null; ip link set eth2 up 2>/dev/null
ip addr flush dev eth3 2>/dev/null; ip addr add 10.67.3.1/24 dev eth3 2>/dev/null; ip link set eth3 up 2>/dev/null
ip addr flush dev eth4 2>/dev/null; ip addr add 10.67.4.1/24 dev eth4 2>/dev/null; ip link set eth4 up 2>/dev/null

# 2. DNS resolver
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 3. IPv4 Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# 4. Source NAT (MASQUERADE)
command -v iptables >/dev/null || { apt update && apt install -y iptables; }
iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# 5. Pulihkan & jalankan DHCP Relay jika sudah terpasang
if [ -f /root/isc-dhcp-relay ]; then
    cp /root/isc-dhcp-relay /etc/default/isc-dhcp-relay
fi
if command -v dhcrelay >/dev/null 2>&1; then
    service isc-dhcp-relay restart
fi
EOF
chmod +x /root/init.sh

echo "[+] Konfigurasi jichi selesai!"
ip -4 addr show
iptables -t nat -L POSTROUTING -v -n
