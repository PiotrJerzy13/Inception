FROM alpine:3.18

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
    mariadb-client \
    curl \
    bash

# Create www-data user and group explicitly
RUN addgroup -g 82 -S www-data || true && \
    adduser -u 82 -D -S -G www-data www-data || true

WORKDIR /var/www/html

RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

# Verify the user and group exist before attempting chown
RUN id www-data && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Configure php-fpm to run as www-data
COPY conf/www.conf /etc/php81/php-fpm.d/www.conf

RUN mkdir -p /var/www/html/static && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 9000

CMD ["php-fpm81", "-F"]
