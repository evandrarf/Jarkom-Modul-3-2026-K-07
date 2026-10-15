cat > /root/14.sh << 'EOF'
#!/bin/bash
# 14.sh (frontend: maki, panda) - Nginx + PHP-FPM
# Peta IP: geto=10.67.4.2 maki=10.67.4.3 panda=10.67.4.4
#          nanami=10.67.4.5 todo=10.67.4.6 kirara=10.67.4.7
#          yaga=10.67.4.8 inumaki=10.67.4.9 tengen=10.67.4.10 gojo=10.67.1.4

echo "nameserver 192.168.122.1" > /etc/resolv.conf

if ! command -v nginx >/dev/null 2>&1 || [ ! -x /usr/sbin/php-fpm8.4 ]; then
    apt-get update
    apt-get install -y nginx php-fpm curl
fi

mkdir -p /var/www/jujutsu
cat > /var/www/jujutsu/index.php << 'EOT'
<?php
header('Content-Type: text/plain');
echo "Frontend: " . gethostname() . "\n";
EOT

rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/jujutsu << 'EOT'
server {
    listen 80;
    server_name jujutsu.k07.com www.jujutsu.k07.com;
    root /var/www/jujutsu;
    index index.php;

    # Hanya reverse proxy gojo (dan localhost untuk tes)
    allow 10.67.1.4;
    allow 127.0.0.1;
    deny all;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOT
ln -sf /etc/nginx/sites-available/jujutsu /etc/nginx/sites-enabled/jujutsu

service php8.4-fpm restart
nginx -t && service nginx restart
EOF
