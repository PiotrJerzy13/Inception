FROM alpine:3.18

# Install required packages
RUN apk add --no-cache \
    php81 \
    php81-session \
    php81-mysqli \
    php81-pdo_mysql \
    php81-pdo \
    php81-json \
    php81-mbstring \
    wget

WORKDIR /var/www/localhost/htdocs

# Download Adminer using wget instead of curl
RUN wget -O index.php "https://www.adminer.org/latest-en.php"

# Add a test file
RUN echo "<?php phpinfo(); ?>" > info.php

EXPOSE 8080

CMD ["php81", "-S", "0.0.0.0:8080", "-t", "/var/www/localhost/htdocs"]
