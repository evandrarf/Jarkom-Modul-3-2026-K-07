#!/bin/bash
# scripts/soal-2/setup.sh
# Konfigurasi isc-dhcp-server pada node tengen (10.67.4.10)

# 1. Pastikan DNS resolver terarah ke internet gateway untuk instalasi paket
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update && apt install -y isc-dhcp-server

# 2. Tetapkan interface IPv4 ke eth0
cat << 'EOF' > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF
cp /etc/default/isc-dhcp-server /root/isc-dhcp-server

# 3. Pastikan direktori dan file leases tersedia
mkdir -p /var/lib/dhcp /etc/dhcp
touch /var/lib/dhcp/dhcpd.leases

# 4. Konfigurasi dasar dhcpd.conf dengan deklarasi subnet lokal Network 4
cat << 'EOF' > /etc/dhcp/dhcpd.conf
# dhcpd.conf - Soal 2
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

# Subnet lokal Network 4 (Data Center) tanpa pool dinamis (mengatasi error "No subnet declaration")
subnet 10.67.4.0 netmask 255.255.255.0 {
}

# Scope DHCP Network 2 (Divisi A)
subnet 10.67.2.0 netmask 255.255.255.0 {
    option routers 10.67.2.1;
    option broadcast-address 10.67.2.255;
    option domain-name-servers 10.67.1.2, 10.67.1.3;
    option domain-name "k07.com";
    option domain-search "k07.com";
    range 10.67.2.10 10.67.2.95;
}

# Scope DHCP Network 3 (Divisi B)
subnet 10.67.3.0 netmask 255.255.255.0 {
    option routers 10.67.3.1;
    option broadcast-address 10.67.3.255;
    option domain-name-servers 10.67.1.2, 10.67.1.3;
    option domain-name "k07.com";
    option domain-search "k07.com";
    range 10.67.3.10 10.67.3.199;
}
EOF
cp /etc/dhcp/dhcpd.conf /root/dhcpd.conf

# 5. Konfigurasi persistensi /root/init.sh pada tengen
cat << 'EOF' > /root/init.sh
#!/bin/bash
# /root/init.sh (tengen)
if [ -f /root/interfaces ]; then
    cp /root/interfaces /etc/network/interfaces
fi
ip addr flush dev eth0 2>/dev/null
ip addr add 10.67.4.10/24 dev eth0 2>/dev/null
ip link set eth0 up 2>/dev/null
ip route replace default via 10.67.4.1 dev eth0 2>/dev/null

echo "nameserver 192.168.122.1" > /etc/resolv.conf

mkdir -p /etc/dhcp /etc/default /var/lib/dhcp
[ -f /root/dhcpd.conf ] && cp /root/dhcpd.conf /etc/dhcp/dhcpd.conf
[ -f /root/isc-dhcp-server ] && cp /root/isc-dhcp-server /etc/default/isc-dhcp-server
touch /var/lib/dhcp/dhcpd.leases

if command -v dhcpd >/dev/null 2>&1; then
    service isc-dhcp-server restart
fi
EOF
chmod +x /root/init.sh

# 6. Validasi sintaks konfigurasi
dhcpd -t -cf /etc/dhcp/dhcpd.conf

# 7. Restart dan cek status service
service isc-dhcp-server restart
service isc-dhcp-server status
