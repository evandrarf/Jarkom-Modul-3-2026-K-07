#!/bin/sh
# scripts/soal-8/trigger_dhcp.sh
# Dijalankan pada salah satu client (misalnya itadori di Network 2 atau ino di Network 3)

HOST=$(hostname)
echo "[*] Client $HOST: Melepaskan IP dan meminta lease baru untuk memicu 4-way DHCP handshake..."
killall udhcpc 2>/dev/null
ip addr flush dev eth0
udhcpc -i eth0 -x hostname:$HOST

echo "[+] Selesai! Alamat yang diperoleh:"
ip -4 addr show eth0 | grep inet
echo "[+] Periksa jendela tcpdump pada tengen untuk menganalisis urutan DORA dan field giaddr."
