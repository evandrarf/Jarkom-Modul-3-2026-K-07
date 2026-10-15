cat > /root/13.sh << 'EOF'
#!/bin/bash
# 13.sh (inumaki) - MariaDB Slave db_shibuya_K07

echo "nameserver 192.168.122.1" > /etc/resolv.conf

if ! command -v mariadbd >/dev/null 2>&1 && ! command -v mysqld >/dev/null 2>&1; then
    apt-get update
    apt-get install -y mariadb-server mariadb-client
fi

cat > /etc/mysql/mariadb.conf.d/99-replication.cnf << 'EOT'
[mysqld]
bind-address = 0.0.0.0
server-id    = 2
log-bin      = mysql-bin
relay-log    = relay-bin
read_only    = 1
EOT

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld 2>/dev/null

service mariadb restart || service mysql restart

for i in $(seq 1 30); do
    mariadb -e "SELECT 1" >/dev/null 2>&1 && break
    sleep 1
done

# Hanya set koneksi master kalau belum pernah dikonfigurasi
if [ -z "$(mariadb -N -e 'SHOW SLAVE STATUS\G' 2>/dev/null)" ]; then
mariadb << 'EOSQL'
CHANGE MASTER TO
    MASTER_HOST='10.67.4.8',
    MASTER_USER='repl',
    MASTER_PASSWORD='repl_k07',
    MASTER_USE_GTID=slave_pos;
START SLAVE;
EOSQL
else
    mariadb -e "START SLAVE;"
fi

mariadb << 'EOSQL'
CREATE USER IF NOT EXISTS 'k07'@'10.67.4.%' IDENTIFIED BY 'k07_pass';
GRANT ALL PRIVILEGES ON db_shibuya_K07.* TO 'k07'@'10.67.4.%';
FLUSH PRIVILEGES;
EOSQL
EOF

