cat > /root/18.sh << 'EOF'
#!/bin/bash
# 18.sh (geto) - superset 17.sh + kirara backup + passive health check

echo "nameserver 192.168.122.1" > /etc/resolv.conf
for i in $(seq 1 30); do getent hosts deb.debian.org >/dev/null 2>&1 && break; sleep 2; done

if ! command -v nginx >/dev/null 2>&1; then
    apt-get update
    apt-get install -y nginx curl
fi

rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/conf.d/api-lb.conf << 'EOT'
upstream api_cluster {
    server 10.67.4.5 weight=3 max_fails=2 fail_timeout=5s;   # nanami
    server 10.67.4.6 weight=1 max_fails=2 fail_timeout=5s;   # todo
    server 10.67.4.7 backup;                                 # kirara
}

server {
    listen 80 default_server;
    server_name _;

    set_real_ip_from 10.67.1.4;
    real_ip_header X-Forwarded-For;
    real_ip_recursive off;

    location /api {
        proxy_pass http://api_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_next_upstream error timeout http_502 http_503 http_504;
        proxy_connect_timeout 2s;
    }
}
EOT

nginx -t && service nginx restart
EOF