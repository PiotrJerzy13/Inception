#!/bin/sh
set -e

# Load secrets from Docker secrets if available
[ -f "$MYSQL_ROOT_PASSWORD_FILE" ] && export MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
[ -f "$MYSQL_PASSWORD_FILE" ] && export MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")
[ -f "$MYSQL_USER_FILE" ] && export MYSQL_USER=$(cat "$MYSQL_USER_FILE")

# Prepare runtime directory
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize DB only if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    echo "Creating database and users..."
    /usr/bin/mysqld --user=mysql --bootstrap << EOF
SET @@SESSION.SQL_LOG_BIN=0;
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS 'guest'@'%' IDENTIFIED BY 'guestpassword';
GRANT SELECT ON ${MYSQL_DATABASE}.* TO 'guest'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    echo "MariaDB init done."
else
    echo "MariaDB already initialized. Skipping setup."
fi

# ▶ Start MariaDB in foreground (PID 1)
exec mysqld --user=mysql --console
