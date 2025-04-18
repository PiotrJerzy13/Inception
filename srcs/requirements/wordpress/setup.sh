#!/bin/sh
set -e

# Set environment variable for WP-CLI memory limit
export WP_CLI_PHP_ARGS='-d memory_limit=256M'

echo "Waiting for MariaDB to be ready..."

# Read secrets
WP_DB_USER=$(cat /run/secrets/credentials)
WP_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)

# Wait for MariaDB (with timeout)
for i in $(seq 1 30); do
    if mysqladmin ping -h "${WP_DB_HOST}" -u"${WP_DB_USER}" -p"${WP_DB_PASSWORD}" --silent; then
        echo "MariaDB is ready."
        break
    fi
    sleep 1
    if [ "$i" -eq 30 ]; then
        echo "MariaDB connection failed after 30 seconds"
        exit 1
    fi
done

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Download WordPress core if not present
if [ ! -f /var/www/html/wp-settings.php ]; then
    echo "Downloading WordPress..."
    su-exec www-data wp core download --path=/var/www/html --allow-root
fi

# Create wp-config.php if not present
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    su-exec www-data wp config create \
        --dbname="${WP_DB_NAME}" \
        --dbuser="${WP_DB_USER}" \
        --dbpass="${WP_DB_PASSWORD}" \
        --dbhost="${WP_DB_HOST}" \
        --path=/var/www/html \
        --allow-root
fi

# Install WordPress if not installed
if ! su-exec www-data wp core is-installed --path=/var/www/html --allow-root; then
    echo "Installing WordPress..."
    su-exec www-data wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception WP" \
        --admin_user=piotr \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="admin@${DOMAIN_NAME}" \
        --skip-email \
        --path=/var/www/html \
        --allow-root
        
    # Create a second non-admin user
    echo "Creating standard user..."
    su-exec www-data wp user create \
        user2 \
        "user2@${DOMAIN_NAME}" \
        --role=editor \
        --user_pass="userPassword123" \
        --path=/var/www/html \
        --allow-root
else
    # Handle existing installation
    # Check if piotr user exists, create if it doesn't
    if ! su-exec www-data wp user get piotr --field=login --path=/var/www/html --allow-root >/dev/null 2>&1; then
        echo "Creating piotr admin user..."
        su-exec www-data wp user create \
            piotr \
            "piotr@${DOMAIN_NAME}" \
            --role=administrator \
            --user_pass="${WP_ADMIN_PASSWORD}" \
            --path=/var/www/html \
            --allow-root
    fi
    
    # Create user2 if it doesn't exist
    if ! su-exec www-data wp user get user2 --field=login --path=/var/www/html --allow-root >/dev/null 2>&1; then
        echo "Adding standard user..."
        su-exec www-data wp user create \
            user2 \
            "user2@${DOMAIN_NAME}" \
            --role=editor \
            --user_pass="userPassword123" \
            --path=/var/www/html \
            --allow-root
    fi
fi

# Keep the container running
echo "WordPress setup complete. Starting PHP-FPM..."
exec php-fpm81 -F