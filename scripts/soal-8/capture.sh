#!/bin/bash
# scripts/soal-8/capture.sh
# Dijalankan pada node tengen (atau jichi eth4) untuk menangkap proses DORA

# Pastikan tcpdump terpasang
command -v tcpdump >/dev/null || { apt update && apt install -y tcpdump; }

echo "[*] Memulai packet capture port 67/68 (DHCP) dengan detail verbose..."
echo "[*] Menunggu paket DHCP... Jalankan script trigger_dhcp.sh pada client di jendela terpisah!"
tcpdump -i eth0 -n -vvv -e -s 0 port 67 or port 68
