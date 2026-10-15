cat > /root/15.sh << 'EOF'
#!/bin/bash
# 15.sh (geto) - Nginx LB, upstream api_cluster nanami:todo = 3:1

echo "nameserver 192.168.122.1" > /etc/resolv.conf

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

    location /api {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
    }
}
EOT

nginx -t && service nginx restart
EOF