cat > /root/13.sh << 'EOF'
#!/bin/bash
# 13.sh (yaga) - MariaDB Master db_shibuya_K07

echo "nameserver 192.168.122.1" > /etc/resolv.conf

if ! command -v mariadbd >/dev/null 2>&1 && ! command -v mysqld >/dev/null 2>&1; then
    apt-get update
    apt-get install -y mariadb-server mariadb-client
fi

# File 99 dibaca setelah 50-server.cnf, jadi bind-address bawaan (127.0.0.1) tertimpa
cat > /etc/mysql/mariadb.conf.d/99-replication.cnf << 'EOT'
[mysqld]
bind-address = 0.0.0.0
server-id    = 1
log-bin      = mysql-bin
binlog_format = ROW
EOT

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld 2>/dev/null

service mariadb restart || service mysql restart

# Tunggu sampai server siap
for i in $(seq 1 30); do
    mariadb -e "SELECT 1" >/dev/null 2>&1 && break
    sleep 1
done

mariadb << 'EOSQL'
CREATE DATABASE IF NOT EXISTS db_shibuya_K07;
USE db_shibuya_K07;
CREATE TABLE IF NOT EXISTS request_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    worker VARCHAR(50),
    client_ip VARCHAR(45),
    path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE USER IF NOT EXISTS 'repl'@'10.67.4.%' IDENTIFIED BY 'repl_k07';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'10.67.4.%';

CREATE USER IF NOT EXISTS 'k07'@'10.67.4.%' IDENTIFIED BY 'k07_pass';
GRANT ALL PRIVILEGES ON db_shibuya_K07.* TO 'k07'@'10.67.4.%';
FLUSH PRIVILEGES;
EOSQL
EOF

