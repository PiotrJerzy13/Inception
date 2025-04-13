FROM alpine:3.18

RUN apk update && apk add --no-cache mariadb mariadb-client

# Optional - custom my.cnf
COPY conf/my.cnf /etc/my.cnf

# Copy setup.sh directly (not to /docker-entrypoint-initdb.d)
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 3306

VOLUME /var/lib/mysql

ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

ENTRYPOINT ["/setup.sh"]
