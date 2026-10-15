#!/bin/bash
# scripts/soal-4/setup.sh
# Konfigurasi DHCP Class dan Dual Pool pada Network 2 (Divisi A) di node tengen

cat << 'EOF' > /etc/dhcp/dhcpd.conf
# dhcpd.conf - Update Soal 4
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

# DHCP Class Divisi A - Tim Dev (itadori, fushiguro)
class "divisi-a-dev" {
    match if option host-name = "itadori"
          or option host-name = "fushiguro"
          or substring(option dhcp-client-identifier, 1, 20) = "itadori"
          or substring(option dhcp-client-identifier, 1, 20) = "fushiguro"
          or substring(hardware, 1, 6) = 02:42:b7:49:92:00
          or substring(hardware, 1, 6) = 02:42:6c:31:39:00;
}

# DHCP Class Divisi A - Tim Support (zenin, okkotsu)
class "divisi-a-support" {
    match if option host-name = "zenin"
          or option host-name = "okkotsu"
          or substring(option dhcp-client-identifier, 1, 20) = "zenin"
          or substring(option dhcp-client-identifier, 1, 20) = "okkotsu"
          or substring(hardware, 1, 6) = 02:42:31:40:9f:00
          or substring(hardware, 1, 6) = 02:42:cc:a2:9e:00;
}

# Subnet lokal Network 4 (Data Center)
subnet 10.67.4.0 netmask 255.255.255.0 {
}

# Subnet Network 2 (Divisi A) dengan dua pool terpisah
subnet 10.67.2.0 netmask 255.255.255.0 {
    option routers 10.67.2.1;
    option broadcast-address 10.67.2.255;
    option domain-name-servers 10.67.1.2, 10.67.1.3;
    option domain-name "k07.com";
    option domain-search "k07.com";

    # Pool 1: 10.67.2.10 - 10.67.2.35 (Tim Dev: itadori, fushiguro)
    pool {
        allow members of "divisi-a-dev";
        range 10.67.2.10 10.67.2.35;
    }

    # Pool 2: 10.67.2.70 - 10.67.2.95 (Tim Support: zenin, okkotsu)
    # Rentang 10.67.2.36 - 10.67.2.69 sengaja tidak dialokasikan
    pool {
        allow members of "divisi-a-support";
        range 10.67.2.70 10.67.2.95;
    }
}

# Subnet Network 3 (Divisi B) placeholder scope
subnet 10.67.3.0 netmask 255.255.255.0 {
    option routers 10.67.3.1;
    option broadcast-address 10.67.3.255;
    option domain-name-servers 10.67.1.2, 10.67.1.3;
    option domain-name "k07.com";
    option domain-search "k07.com";
    range 10.67.3.10 10.67.3.199;
}
EOF

# Backup ke /root/dhcpd.conf agar persisten saat reboot
cp /etc/dhcp/dhcpd.conf /root/dhcpd.conf

# Validasi dan restart service
dhcpd -t -cf /etc/dhcp/dhcpd.conf && service isc-dhcp-server restart
service isc-dhcp-server status
