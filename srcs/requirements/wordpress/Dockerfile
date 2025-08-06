FROM alpine:3.18

# Install dependencies
RUN apk update && apk add --no-cache \
    php81 php81-fpm php81-mysqli php81-pdo php81-session \
    php81-mbstring php81-opcache php81-curl php81-xml \
    php81-json php81-gd php81-phar php81-redis \
    mariadb-client curl bash su-exec shadow

# Create www-data user/group if they don't exist
RUN set -ex && \
    if ! getent group www-data >/dev/null; then \
        addgroup -g 82 -S www-data; \
    fi && \
    if ! getent passwd www-data >/dev/null; then \
        adduser -u 82 -S -D -G www-data www-data; \
    fi && \
    mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Configure PHP settings
RUN echo "memory_limit = 256M" > /etc/php81/conf.d/memory_limit.ini && \
    { \
        echo 'pm.max_children = 50'; \
        echo 'pm.start_servers = 5'; \
        echo 'pm.min_spare_servers = 5'; \
        echo 'pm.max_spare_servers = 10'; \
    } >> /etc/php81/php-fpm.d/www.conf

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

COPY conf/www.conf /etc/php81/php-fpm.d/www.conf

EXPOSE 9000

VOLUME /var/www/html

ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm81", "-F"]