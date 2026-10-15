#!/bin/sh
# scripts/soal-5/client_renew.sh
# Dijalankan pada client Divisi B (ino, kusakabe, miwa)

HOST=$(hostname)
echo "[*] Requesting IP untuk $HOST via DHCP..."

hostname $HOST 2>/dev/null
echo "$HOST" > /etc/hostname 2>/dev/null

killall udhcpc 2>/dev/null
ip addr flush dev eth0
udhcpc -i eth0 -x hostname:$HOST

echo "[+] Hasil alokasi IP:"
ip -4 addr show eth0 | grep inet
echo "[+] Default Route:"
ip route show
echo "[+] DNS Resolver & Search Domain (/etc/resolv.conf):"
cat /etc/resolv.conf
