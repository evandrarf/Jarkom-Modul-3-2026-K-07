cat > /root/12.sh << 'EOF'
#!/bin/bash
# 12.sh (utahime) - superset 11.sh + A, CNAME, PTR, forwarder

echo "nameserver 192.168.122.1" > /etc/resolv.conf

if ! command -v named >/dev/null 2>&1; then
    apt-get update
    apt-get install -y bind9 bind9utils dnsutils
fi

mkdir -p /etc/bind/jujutsu

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
    type master;
    file "/etc/bind/jujutsu/db.jujutsu.k07.com";
    notify yes;
    allow-transfer { 10.67.1.3; };
    also-notify { 10.67.1.3; };
};

zone "1.67.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jujutsu/db.10.67.1";
};
EOT

cat > /etc/bind/jujutsu/db.jujutsu.k07.com << 'EOT'
$TTL 604800
@   IN  SOA ns1.jujutsu.k07.com. admin.jujutsu.k07.com. (
            2026101403  ; serial
            604800      ; refresh
            86400       ; retry
            2419200     ; expire
            604800 )    ; negative cache
@   IN  NS  ns1.jujutsu.k07.com.
@   IN  NS  ns2.jujutsu.k07.com.
ns1 IN  A   10.67.1.2
ns2 IN  A   10.67.1.3
@   IN  A   10.67.1.4
www IN  CNAME jujutsu.k07.com.
EOT

cat > /etc/bind/jujutsu/db.10.67.1 << 'EOT'
$TTL 604800
@   IN  SOA ns1.jujutsu.k07.com. admin.jujutsu.k07.com. (
            2026101401  ; serial
            604800
            86400
            2419200
            604800 )
@   IN  NS  ns1.jujutsu.k07.com.
@   IN  NS  ns2.jujutsu.k07.com.
4   IN  PTR jujutsu.k07.com.
EOT

chown -R bind:bind /etc/bind/jujutsu 2>/dev/null

named-checkconf \
  && named-checkzone jujutsu.k07.com /etc/bind/jujutsu/db.jujutsu.k07.com \
  && named-checkzone 1.67.10.in-addr.arpa /etc/bind/jujutsu/db.10.67.1 \
  && (service named restart || service bind9 restart)
EOF
chmod +x /root/12.sh
bash /root/12.sh