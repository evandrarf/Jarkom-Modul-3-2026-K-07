#!/bin/bash
# scripts/soal-9/start_relay.sh
# Dijalankan pada node jichi: Memulihkan service DHCP Relay

echo "[*] Menyalakan kembali DHCP Relay pada jichi..."
service isc-dhcp-relay start
service isc-dhcp-relay status && echo "[✔] Service DHCP Relay berhasil dipulihkan!"
