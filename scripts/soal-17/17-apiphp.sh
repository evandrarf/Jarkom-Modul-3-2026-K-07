cat > /root/17.sh << 'EOF'
#!/bin/bash
# 17.sh (nanami, todo, kirara) - api.php mencatat IP asli client

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
$ip = $_SERVER['REMOTE_ADDR'];
if ($ip === '10.67.4.2' && !empty($_SERVER['HTTP_X_REAL_IP'])
    && filter_var($_SERVER['HTTP_X_REAL_IP'], FILTER_VALIDATE_IP)) {
    $ip = $_SERVER['HTTP_X_REAL_IP'];
}
$path = $_SERVER['REQUEST_URI'];
$st = $db->prepare('INSERT INTO request_logs (worker, client_ip, path) VALUES (?, ?, ?)');
$st->bind_param('sss', $worker, $ip, $path);
$ok = $st->execute();
echo json_encode(['worker' => $worker, 'logged' => $ok]);
EOT
EOF
