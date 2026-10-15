#!/bin/bash
# scripts/soal-7/check_leases.sh
# Dijalankan pada node tengen untuk memeriksa daftar lease aktif di /var/lib/dhcp/dhcpd.leases

echo "=========================================="
echo "Daftar Lease Aktif pada Tengen"
echo "=========================================="

if [ -f /var/lib/dhcp/dhcpd.leases ]; then
    grep -E "^lease |hardware ethernet|client-hostname|binding state|starts|ends" /var/lib/dhcp/dhcpd.leases
else
    echo "[!] File /var/lib/dhcp/dhcpd.leases belum tersedia atau kosong."
fi
echo "=========================================="
