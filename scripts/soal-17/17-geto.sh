cat > /root/17.sh << 'EOF'
#!/bin/bash
# 17.sh (geto) - superset 15.sh + realip dari gojo saja

echo "nameserver 192.168.122.1" > /etc/resolv.conf
for i in $(seq 1 30); do getent hosts deb.debian.org >/dev/null 2>&1 && break; sleep 2; done

if ! command -v nginx >/dev/null 2>&1; then
    apt-get update
    apt-get install -y nginx curl
fi

rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/conf.d/api-lb.conf << 'EOT'
upstream api_cluster {
    server 10.67.4.5 weight=3;   # nanami
    server 10.67.4.6 weight=1;   # todo
}

server {
    listen 80 default_server;
    server_name _;

    # Percaya header X-Forwarded-For hanya kalau koneksi datang dari gojo
    set_real_ip_from 10.67.1.4;
    real_ip_header X-Forwarded-For;
    real_ip_recursive off;

    location /api {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOT

nginx -t && service nginx restart
EOF
