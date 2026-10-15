#!/bin/bash
# scripts/soal-1/infra_nodes.sh
# Konfigurasi IP statis host infrastruktur Network 1 (DMZ) dan Network 4 (Data Center)

config_node() {
    local node_name=$1
    local ip=$2
    local gw=$3

    # 1. Konfigurasi /etc/network/interfaces
    cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address $ip
    netmask 255.255.255.0
    gateway $gw
EOF

    # Backup ke /root/interfaces
    cp /etc/network/interfaces /root/interfaces

    # 2. Terapkan konfigurasi antarmuka langsung ke kernel
    ip addr flush dev eth0 2>/dev/null
    ip addr add $ip/24 dev eth0 2>/dev/null
    ip link set eth0 up 2>/dev/null
    ip route replace default via $gw dev eth0 2>/dev/null

    # 3. DNS resolver sementara ke gateway internet
    echo "nameserver 192.168.122.1" > /etc/resolv.conf

    # 4. Simpan ke /root/init.sh agar permanen
    cat << EOF > /root/init.sh
#!/bin/bash
# /root/init.sh ($node_name)
if [ -f /root/interfaces ]; then
    cp /root/interfaces /etc/network/interfaces
fi
ip addr flush dev eth0 2>/dev/null
ip addr add $ip/24 dev eth0 2>/dev/null
ip link set eth0 up 2>/dev/null
ip route replace default via $gw dev eth0 2>/dev/null
echo "nameserver 192.168.122.1" > /etc/resolv.conf
EOF
    chmod +x /root/init.sh

    echo "[+] Konfigurasi $node_name ($ip via $gw) berhasil diterapkan."
}

HOSTNAME=$(hostname)
case "$HOSTNAME" in
    # Network 1 (DMZ) - Gateway: 10.67.1.1
    utahime)
        config_node "utahime" "10.67.1.2" "10.67.1.1"
        ;;
    shoko)
        config_node "shoko" "10.67.1.3" "10.67.1.1"
        ;;
    gojo)
        config_node "gojo" "10.67.1.4" "10.67.1.1"
        ;;

    # Network 4 (Data Center) - Gateway: 10.67.4.1
    geto)
        config_node "geto" "10.67.4.2" "10.67.4.1"
        ;;
    maki)
        config_node "maki" "10.67.4.3" "10.67.4.1"
        ;;
    panda)
        config_node "panda" "10.67.4.4" "10.67.4.1"
        ;;
    nanami)
        config_node "nanami" "10.67.4.5" "10.67.4.1"
        ;;
    todo)
        config_node "todo" "10.67.4.6" "10.67.4.1"
        ;;
    kirara)
        config_node "kirara" "10.67.4.7" "10.67.4.1"
        ;;
    yaga)
        config_node "yaga" "10.67.4.8" "10.67.4.1"
        ;;
    inumaki)
        config_node "inumaki" "10.67.4.9" "10.67.4.1"
        ;;
    tengen)
        config_node "tengen" "10.67.4.10" "10.67.4.1"
        ;;
    *)
        echo "[!] Hostname '$HOSTNAME' tidak dikenali otomatis."
        echo "    Penggunaan manual: config_node <nama_node> <IP> <Gateway>"
        ;;
esac

echo "[*] Uji konektivitas ke gateway..."
ping -c 2 10.67.1.1 2>/dev/null || ping -c 2 10.67.4.1 2>/dev/null
echo "[*] Uji akses eksternal via router..."
ping -c 2 192.168.122.1 2>/dev/null
