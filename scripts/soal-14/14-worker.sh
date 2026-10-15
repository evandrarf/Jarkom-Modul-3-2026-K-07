cat > /root/14.sh << 'EOF'
#!/bin/bash
# 14.sh (API: nanami, todo, kirara) - Nginx + PHP-FPM, log ke yaga
# Peta IP: geto=10.67.4.2 maki=10.67.4.3 panda=10.67.4.4
#          nanami=10.67.4.5 todo=10.67.4.6 kirara=10.67.4.7
#          yaga=10.67.4.8 inumaki=10.67.4.9 tengen=10.67.4.10 gojo=10.67.1.4

echo "nameserver 192.168.122.1" > /etc/resolv.conf

if ! command -v nginx >/dev/null 2>&1 || [ ! -x /usr/sbin/php-fpm8.4 ] || ! php -m | grep -qi mysqli; then
    apt-get update
    apt-get install -y nginx php-fpm php-mysql curl
fi

mkdir -p /var/www/api
cat > /var/www/api/api.php << 'EOT'
<?php
header('Content-Type: application/json');
mysqli_report(MYSQLI_REPORT_OFF);
$worker = gethostname();
$db = @new mysqli('10.67.4.8', 'k07', 'k07_pass', 'db_shibuya_K07');
if ($db->connect_errno) {
    http_response_code(500);
    echo json_encode(['worker' => $worker, 'logged' => false, 'error' => 'db connect failed']);
    exit;
}
$ip   = $_SERVER['REMOTE_ADDR'];
$path = $_SERVER['REQUEST_URI'];
$st = $db->prepare('INSERT INTO request_logs (worker, client_ip, path) VALUES (?, ?, ?)');
$st->bind_param('sss', $worker, $ip, $path);
$ok = $st->execute();
echo json_encode(['worker' => $worker, 'logged' => $ok]);
EOT

rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/jujutsu-api << 'EOT'
server {
    listen 80 default_server;
    server_name jujutsu.k07.com www.jujutsu.k07.com;

    # Hanya geto (dan localhost untuk tes)
    allow 10.67.4.2;
    allow 127.0.0.1;
    deny all;

    location /api {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME /var/www/api/api.php;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }
}
EOT
ln -sf /etc/nginx/sites-available/jujutsu-api /etc/nginx/sites-enabled/jujutsu-api

service php8.4-fpm restart
nginx -t && service nginx restart
EOF
