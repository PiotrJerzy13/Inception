#!/bin/sh
set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize DB only if empty
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

# Start MariaDB as mysql user
exec mysqld --user=mysql --console
