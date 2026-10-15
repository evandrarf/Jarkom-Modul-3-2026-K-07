#!/bin/sh
# scripts/soal-3/test_client.sh
# Pengujian request IP via DHCP Relay dari client (Alpine Linux)

HOST=$(hostname)
echo "[*] Menguji alokasi IP via DHCP Relay pada client: $HOST"
echo "[*] Merilis lease lama..."
killall udhcpc 2>/dev/null
ip addr flush dev eth0

echo "[*] Mengirim permintaan lease baru melalui DHCP Relay..."
udhcpc -i eth0 -x hostname:$HOST

echo "[+] Konfigurasi IP yang diterima:"
ip -4 addr show eth0 | grep inet
echo "[+] Rute default:"
ip route show
echo "[+] DNS Resolver:"
cat /etc/resolv.conf
