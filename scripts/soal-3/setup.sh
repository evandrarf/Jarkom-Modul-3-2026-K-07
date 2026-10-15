#!/bin/bash
# scripts/soal-3/setup.sh
# Konfigurasi DHCP Relay pada node jichi menuju tengen (10.67.4.10)

# 1. DNS resolver untuk instalasi paket
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt update && apt install -y isc-dhcp-relay

# 2. Konfigurasi relay server dan antarmuka
cat << 'EOF' > /etc/default/isc-dhcp-relay
SERVERS="10.67.4.10"
INTERFACES="eth2 eth3 eth4"
OPTIONS=""
EOF
cp /etc/default/isc-dhcp-relay /root/isc-dhcp-relay

# 3. Update /root/init.sh pada jichi agar otomatis memulihkan relay saat boot
if ! grep -q "isc-dhcp-relay" /root/init.sh 2>/dev/null; then
    cat << 'EOF' >> /root/init.sh

# Pulihkan dan jalankan DHCP Relay
if [ -f /root/isc-dhcp-relay ]; then
    cp /root/isc-dhcp-relay /etc/default/isc-dhcp-relay
fi
if command -v dhcrelay >/dev/null 2>&1; then
    service isc-dhcp-relay restart
fi
EOF
fi

# 4. Restart service relay dan cek status
service isc-dhcp-relay restart
service isc-dhcp-relay status
