FROM alpine:3.18

RUN apk add --no-cache nginx

# Create directory structure
RUN mkdir -p /usr/share/nginx/html

# Copy files
COPY html/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

# Set permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]