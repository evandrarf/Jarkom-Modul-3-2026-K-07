#!/bin/sh
# scripts/soal-6/kugisaki_test.sh
# Verifikasi Fixed Address pada client kugisaki

echo "[*] Menyiapkan antarmuka kugisaki dengan MAC VIP (02:42:4d:36:26:00)..."
hostname kugisaki 2>/dev/null
echo "kugisaki" > /etc/hostname 2>/dev/null

ip link set dev eth0 down 2>/dev/null
ip link set dev eth0 address 02:42:4d:36:26:00 2>/dev/null
ip link set dev eth0 up 2>/dev/null

echo "[*] Memperbarui lease pada kugisaki..."
killall udhcpc 2>/dev/null
ip addr flush dev eth0
udhcpc -i eth0 -x hostname:kugisaki

echo "[+] Alamat IP yang diperoleh:"
ip -4 addr show eth0 | grep inet

echo "[+] Memeriksa apakah IP sesuai reservasi VIP (10.67.3.99):"
CURRENT_IP=$(ip -4 addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1)
if [ "$CURRENT_IP" = "10.67.3.99" ]; then
    echo "[✔] SUKSES: kugisaki berhasil menerima fixed-address 10.67.3.99!"
else
    echo "[!] PERINGATAN: IP yang diperoleh ($CURRENT_IP) tidak sesuai!"
fi
