#!/bin/bash
# scripts/soal-9/stop_relay.sh
# Dijalankan pada node jichi: Menghentikan service DHCP Relay untuk simulasi gangguan

echo "[*] Menghentikan DHCP Relay pada jichi..."
service isc-dhcp-relay stop 2>/dev/null || killall dhcrelay 2>/dev/null
echo "[+] Status layanan isc-dhcp-relay:"
service isc-dhcp-relay status 2>&1 || echo "[✔] Service DHCP Relay berhasil dimatikan."
