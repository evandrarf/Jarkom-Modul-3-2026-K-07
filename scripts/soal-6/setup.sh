#!/bin/bash
# scripts/soal-6/setup.sh
# Konfigurasi Fixed Address (Static Lease) untuk VIP kugisaki pada node tengen

cat << 'EOF' > /etc/dhcp/dhcpd.conf
# dhcpd.conf - Update Soal 6
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;
authoritative;

# DHCP Classes Divisi A
class "divisi-a-dev" {
    match if option host-name = "itadori"
          or option host-name = "fushiguro"
          or substring(option dhcp-client-identifier, 1, 20) = "itadori"
          or substring(option dhcp-client-identifier, 1, 20) = "fushiguro"
          or substring(hardware, 1, 6) = 02:42:b7:49:92:00
          or substring(hardware, 1, 6) = 02:42:6c:31:39:00;
}

class "divisi-a-support" {
    match if option host-name = "zenin"
          or option host-name = "okkotsu"
          or substring(option dhcp-client-identifier, 1, 20) = "zenin"
          or substring(option dhcp-client-identifier, 1, 20) = "okkotsu"
          or substring(hardware, 1, 6) = 02:42:31:40:9f:00
          or substring(hardware, 1, 6) = 02:42:cc:a2:9e:00;
}

# DHCP Classes Divisi B
class "divisi-b-short" {
    match if option host-name = "ino"
          or option host-name = "kusakabe"
          or substring(option dhcp-client-identifier, 1, 20) = "ino"
          or substring(option dhcp-client-identifier, 1, 20) = "kusakabe"
          or substring(hardware, 1, 6) = 02:42:e5:ec:d0:00
          or substring(hardware, 1, 6) = 02:42:a2:f9:8e:00;
}

class "divisi-b-long" {
    match if option host-name = "miwa"
          or substring(option dhcp-client-identifier, 1, 20) = "miwa"
          or substring(hardware, 1, 6) = 02:42:12:55:91:00;
}

# Subnet lokal Network 4 (Data Center)
subnet 10.67.4.0 netmask 255.255.255.0 {
}

# Subnet Network 2 (Divisi A)
subnet 10.67.2.0 netmask 255.255.255.0 {
    option routers 10.67.2.1;
    option broadcast-address 10.67.2.255;
    option domain-name-servers 10.67.1.2, 10.67.1.3;
    option domain-name "k07.com";
    option domain-search "k07.com";

    pool {
        allow members of "divisi-a-dev";
        range 10.67.2.10 10.67.2.35;
    }

    pool {
        allow members of "divisi-a-support";
        range 10.67.2.70 10.67.2.95;
    }
}

# Subnet Network 3 (Divisi B)
subnet 10.67.3.0 netmask 255.255.255.0 {
    option routers 10.67.3.1;
    option broadcast-address 10.67.3.255;
    option domain-name-servers 10.67.1.2, 10.67.1.3;
    option domain-name "k07.com";
    option domain-search "k07.com";

    # Short Lease: 10.67.3.10 - 10.67.3.89
    pool {
        allow members of "divisi-b-short";
        range 10.67.3.10 10.67.3.89;
        default-lease-time 1800;
        max-lease-time 1800;
    }

    # Long Lease: 10.67.3.100 - 10.67.3.199
    pool {
        allow members of "divisi-b-long";
        range 10.67.3.100 10.67.3.199;
        default-lease-time 43200;
        max-lease-time 43200;
    }
}

# Static Lease (Fixed Address) untuk Personel VIP kugisaki
# Alamat 10.67.3.99 berada tepat di luar seluruh pool dinamis
host kugisaki {
    hardware ethernet 02:42:4d:36:26:00;
    fixed-address 10.67.3.99;
}
EOF

# Backup ke /root/dhcpd.conf agar persisten
cp /etc/dhcp/dhcpd.conf /root/dhcpd.conf

# Validasi sintaks dan restart service
dhcpd -t -cf /etc/dhcp/dhcpd.conf && service isc-dhcp-server restart
service isc-dhcp-server status
