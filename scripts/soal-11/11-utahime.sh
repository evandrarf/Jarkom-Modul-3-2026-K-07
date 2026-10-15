cat > /root/11.sh << 'EOF'
#!/bin/bash
apt-get update
apt-get install -y bind9 bind9utils dnsutils
EOF
chmod +x /root/11.sh
/root/11.sh


--- 

cat > /root/11.sh << 'EOF'
#!/bin/bash
mkdir -p /etc/bind/jujutsu

cat > /etc/bind/named.conf.options << 'EOT'
options {
    directory "/var/cache/bind";
    listen-on { any; };
    allow-query { any; };
    recursion yes;
    allow-recursion { 10.67.0.0/16; 127.0.0.1; };
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
EOT

cat > /etc/bind/jujutsu/db.jujutsu.k07.com << 'EOT'
$TTL 604800
@   IN  SOA ns1.jujutsu.k07.com. admin.jujutsu.k07.com. (
            2026101401  ; serial
            604800      ; refresh
            86400       ; retry
            2419200     ; expire
            604800 )    ; negative cache
@   IN  NS  ns1.jujutsu.k07.com.
@   IN  NS  ns2.jujutsu.k07.com.
ns1 IN  A   10.67.1.2
ns2 IN  A   10.67.1.3
EOT

named-checkconf && named-checkzone jujutsu.k07.com /etc/bind/jujutsu/db.jujutsu.k07.com
service named restart || service bind9 restart
EOF
chmod +x /root/11.sh
/root/11.sh

