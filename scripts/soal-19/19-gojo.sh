cat > /root/19.sh << 'EOF'
#!/bin/bash
# 19.sh (gojo) - superset 17.sh + proxy cache 10m + rate limit /api 10r/s

echo "nameserver 192.168.122.1" > /etc/resolv.conf
for i in $(seq 1 30); do getent hosts deb.debian.org >/dev/null 2>&1 && break; sleep 2; done

if ! command -v nginx >/dev/null 2>&1; then
    apt-get update
    apt-get install -y nginx curl
fi

mkdir -p /var/cache/nginx/jujutsu
rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/conf.d/gojo.conf << 'EOT'
proxy_cache_path /var/cache/nginx/jujutsu levels=1:2 keys_zone=web_cache:10m max_size=100m inactive=10m;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

upstream frontend {
    server 10.67.4.3;   # maki
    server 10.67.4.4;   # panda
}

server {
    listen 80;
    server_name jujutsu.k07.com www.jujutsu.k07.com;

    location /api {
        limit_req zone=api_limit;
        proxy_pass http://10.67.4.2;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        proxy_cache web_cache;
        proxy_cache_valid 200 10m;
        add_header X-Cache-Status $upstream_cache_status;
        proxy_pass http://frontend;
        proxy_set_header Host $host;
    }
}
EOT

nginx -t && service nginx restart
EOF
