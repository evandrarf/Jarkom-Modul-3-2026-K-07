#!/bin/sh
# scripts/soal-4/client_renew.sh
# Dijalankan pada client Divisi A (itadori, fushiguro, zenin, okkotsu)

HOST=$(hostname)
echo "[*] Requesting IP untuk $HOST via DHCP..."

# Tetapkan hostname eksplisit
hostname $HOST 2>/dev/null
echo "$HOST" > /etc/hostname 2>/dev/null

killall udhcpc 2>/dev/null
ip addr flush dev eth0
udhcpc -i eth0 -x hostname:$HOST

echo "[+] Hasil alokasi IP untuk $HOST:"
ip -4 addr show eth0 | grep inet
echo "[+] Default Route:"
ip route show
