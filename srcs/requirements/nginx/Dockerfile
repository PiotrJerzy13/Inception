FROM alpine:3.18

# Install nginx & openssl (for TLS/SSL)
RUN apk update && apk add --no-cache nginx openssl bash curl

# Create necessary dirs
RUN mkdir -p /var/www/html /run/nginx /etc/nginx/ssl

# Add www-data group and user if they don't exist
RUN addgroup -g 82 -S www-data || true && \
    adduser -u 82 -D -S -G www-data www-data || true

# Copy custom nginx config
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copy startup script
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Expose HTTPS port only
EXPOSE 443

# Set entrypoint to our setup script
ENTRYPOINT ["/setup.sh"]

# Run nginx in foreground - this will be executed by the setup script
CMD ["nginx", "-g", "daemon off;"]
