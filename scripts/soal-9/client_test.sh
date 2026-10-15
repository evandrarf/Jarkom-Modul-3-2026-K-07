#!/bin/sh
# scripts/soal-9/client_test.sh
# Dijalankan pada client (misal itadori atau ino) untuk menguji permintaan lease saat relay mati vs hidup

HOST=$(hostname)
echo "[*] Menguji permintaan lease pada client $HOST..."
killall udhcpc 2>/dev/null
ip addr flush dev eth0

echo "[*] Mencoba meminta lease baru (timeout 5 detik)..."
udhcpc -i eth0 -n -t 5 -x hostname:$HOST

if [ $? -ne 0 ]; then
    echo "[!] HASIL: Gagal memperoleh lease! (Permintaan broadcast tidak diteruskan ke Data Center karena relay terputus)"
else
    echo "[✔] HASIL: Berhasil memperoleh lease melalui relay!"
    ip -4 addr show eth0 | grep inet
    ip route show
fi
