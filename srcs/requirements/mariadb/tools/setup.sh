#!/bin/sh
set -e

# Load secrets from Docker secrets
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

    # Start MariaDB temporarily in safe mode without networking
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    
    # Wait for server to start
    for i in {1..30}; do
        if [ -S /run/mysqld/mysqld.sock ] && mysqladmin ping --socket=/run/mysqld/mysqld.sock 2>/dev/null; then
            break
        fi
        echo "Waiting for database server to accept connections... ($i/30)"
        sleep 1
    done

    # Secure the installation and set up database
    mysql --socket=/run/mysqld/mysqld.sock <<-EOSQL
        -- Remove anonymous users
        DELETE FROM mysql.user WHERE User='';
        
        -- Remove test database
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        
        -- Create application database
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        
        -- Create application user
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        
        -- Create guest user
        CREATE USER IF NOT EXISTS 'guest'@'%' IDENTIFIED BY 'guestpassword';
        GRANT SELECT ON \`${MYSQL_DATABASE}\`.* TO 'guest'@'%';
        
        -- Set root passwords (compatible with MariaDB 10.11)
        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
        -- First try to create the root@% user if it doesn't exist
        CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        -- Then set the password
        SET PASSWORD FOR 'root'@'%' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
        FLUSH PRIVILEGES;
EOSQL

    # Stop the temporary instance
    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p${MYSQL_ROOT_PASSWORD} shutdown
    
    echo "MariaDB init done."
else
    echo "MariaDB already initialized. Skipping setup."
fi

# Start MariaDB normally
echo "Starting MariaDB..."
exec mysqld --user=mysql --console