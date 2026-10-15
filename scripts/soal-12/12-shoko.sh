cat > /root/12.sh << 'EOF'
#!/bin/bash
# 12.sh (shoko) - DNS Slave jujutsu.k07.com + forwarder

echo "nameserver 192.168.122.1" > /etc/resolv.conf

if ! command -v named >/dev/null 2>&1; then
    apt-get update
    apt-get install -y bind9 bind9utils dnsutils
fi

mkdir -p /var/cache/bind/slaves
chown -R bind:bind /var/cache/bind/slaves 2>/dev/null

cat > /etc/bind/named.conf.options << 'EOT'
options {
    directory "/var/cache/bind";
    listen-on { any; };
    allow-query { any; };
    recursion yes;
    allow-recursion { 10.67.0.0/16; 127.0.0.1; };
    forwarders { 192.168.122.1; };
    forward only;
    dnssec-validation no;
};
EOT

cat > /etc/bind/named.conf.local << 'EOT'
zone "jujutsu.k07.com" {
    type slave;
    masters { 10.67.1.2; };
    file "/var/cache/bind/slaves/db.jujutsu.k07.com";
};
EOT

named-checkconf && (service named restart || service bind9 restart)
EOF
