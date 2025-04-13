# Start from Alpine Linux
FROM alpine:3.18

# Install php-fpm, php extensions, mariadb-client, curl, bash
RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-pdo \
    php81-session \
    php81-mbstring \
    php81-opcache \
    php81-curl \
    php81-xml \
    php81-json \
    php81-gd \
    php81-tokenizer \
    curl \
    mariadb-client \
    bash \
    supervisor

# Set working directory
WORKDIR /var/www/html

# Download & extract latest WordPress
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

# Copy custom wp-config.php if using static one (optional)
# COPY wp-config/wp-config.php /var/www/html/wp-config.php

# Set correct permissions for WordPress files
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Expose php-fpm port
EXPOSE 9000

# Start php-fpm in foreground (important for Docker)
CMD ["php-fpm81", "-F"]
