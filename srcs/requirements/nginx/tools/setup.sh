#!/bin/sh
set -e

echo "Generating SSL certificate..."

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/nginx/ssl/server.key \
-out /etc/nginx/ssl/server.crt \
-subj "/C=PL/ST=42/L=Student/O=42/OU=Inception/CN=${DOMAIN_NAME}"

echo "Replacing domain name in nginx config..."
sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf

echo "Setting correct permissions..."
chown -R www-data:www-data /etc/nginx/ssl

echo "Starting nginx..."
exec nginx -g "daemon off;"

