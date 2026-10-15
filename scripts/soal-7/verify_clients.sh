#!/bin/sh
# scripts/soal-7/verify_clients.sh
# Verifikasi parameter jaringan pada setiap client (Divisi A dan Divisi B)

echo "=========================================="
echo "Host: $(hostname)"
echo "=========================================="
echo "[+] MAC Address eth0:"
ip link show eth0 | grep link/ether

echo "[+] IP Address & Netmask:"
ip -4 addr show eth0 | grep inet

echo "[+] Default Gateway & Routing Table:"
ip route show

echo "[+] DNS Resolver & Domain Search (/etc/resolv.conf):"
cat /etc/resolv.conf
echo "=========================================="
