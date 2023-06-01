FROM alpine:3.10

LABEL maintainer="Ghanmy Mohsen <ghanmy@mobiblanc.com"

RUN apk add --update --no-cache nginx

COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/conf.d/
RUN echo "upstream php-upstream { server php:9000; }" > /etc/nginx/conf.d/upstream.conf

RUN adduser -D -g '' -G www-data www-data

CMD ["nginx"]
