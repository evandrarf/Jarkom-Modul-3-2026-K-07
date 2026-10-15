cat > /root/16.sh << 'EOF'
#!/bin/bash
# 16.sh (gojo) - Reverse proxy: / -> maki,panda (RR), /api -> geto

echo "nameserver 192.168.122.1" > /etc/resolv.conf

if ! command -v nginx >/dev/null 2>&1; then
    apt-get update
    apt-get install -y nginx curl
fi

rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/conf.d/gojo.conf << 'EOT'
upstream frontend {
    server 10.67.4.3;   # maki
    server 10.67.4.4;   # panda
}

server {
    listen 80;
    server_name jujutsu.k07.com www.jujutsu.k07.com;

    location /api {
        proxy_pass http://10.67.4.2;
        proxy_set_header Host $host;
    }

    location / {
        proxy_pass http://frontend;
        proxy_set_header Host $host;
    }
}
EOT

nginx -t && service nginx restart
EOF
