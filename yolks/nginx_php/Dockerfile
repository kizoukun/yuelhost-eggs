ARG ALPINE_VERSION=3.24
FROM composer:2 AS composer

FROM alpine:${ALPINE_VERSION}
ARG PHP_VERSION=84

LABEL org.opencontainers.image.source="https://github.com/kizoukun/yuelhost-eggs" \
      org.opencontainers.image.description="Nginx + PHP-FPM yolk for Pterodactyl web hosting eggs" \
      org.opencontainers.image.licenses="MIT"

RUN set -eu; \
    exts="bcmath bz2 calendar ctype curl dom exif fileinfo gd gettext gmp iconv intl mbstring mysqli opcache openssl \
          pdo pdo_mysql pdo_pgsql pdo_sqlite pecl-apcu pecl-imagick pecl-redis pgsql phar posix session simplexml \
          soap sockets sodium sqlite3 tokenizer xml xmlreader xmlwriter xsl zip"; \
    # PHP 8.5 ships OPcache built in, so there is no separate package.
    if [ "$PHP_VERSION" -ge 85 ]; then exts=$(echo " $exts " | sed 's/ opcache / /'); fi; \
    pkgs=""; \
    for ext in $exts; do pkgs="$pkgs php${PHP_VERSION}-${ext}"; done; \
    apk add --no-cache bash tini git curl unzip tar xz ca-certificates iproute2 nginx \
        "php${PHP_VERSION}" "php${PHP_VERSION}-fpm" $pkgs; \
    ln -sf "/usr/sbin/php-fpm${PHP_VERSION}" /usr/local/bin/php-fpm; \
    ln -sf "/usr/bin/php${PHP_VERSION}" /usr/local/bin/php; \
    adduser -D -h /home/container container

COPY --from=composer /usr/bin/composer /usr/local/bin/composer
COPY defaults/ /opt/webhost/
COPY --chmod=0755 entrypoint.sh /entrypoint.sh
COPY --chmod=0755 start-webhost.sh /usr/local/bin/start-webhost

ENV USER=container \
    HOME=/home/container \
    PHP_INI_SCAN_DIR=:/home/container/php-fpm/conf.d

USER container
WORKDIR /home/container

STOPSIGNAL SIGINT

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
