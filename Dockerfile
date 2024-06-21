FROM php:8.1.2-cli-alpine3.15 as build

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN apk update && apk upgrade

RUN apk add --no-cache curl bash zip unzip \
        libstdc++ libx11 libxrender libxext libssl1.1 fontconfig freetype \
        libldap libzip zlib libpng libjpeg-turbo

RUN apk add --no-cache --virtual build-essentials \
        $PHPIZE_DEPS make automake g++ libstdc++ \
        icu-dev zlib-dev postgresql-dev sqlite-dev libpq-dev curl-dev openssl-dev pcre-dev pcre2-dev \
        openldap-dev ldb-dev libzip-dev libxml2-dev zlib-dev libpng-dev libjpeg-turbo-dev

RUN docker-php-source extract

RUN pecl install -o -f redis
RUN pecl install -D 'enable-openssl="yes" enable-http2="yes" enable-swoole-curl="yes" enable-mysqlnd="yes" with-postgres="yes" enable-cares="yes"' swoole

RUN docker-php-ext-configure intl
RUN docker-php-ext-configure bcmath
RUN docker-php-ext-configure pcntl
RUN docker-php-ext-configure opcache
RUN docker-php-ext-configure pdo_mysql
RUN docker-php-ext-configure pdo_pgsql
RUN docker-php-ext-configure ldap
RUN docker-php-ext-configure soap
RUN docker-php-ext-configure zip
RUN docker-php-ext-configure gd

RUN docker-php-ext-install intl bcmath pcntl opcache pdo_mysql pdo_pgsql ldap zip soap gd

RUN docker-php-ext-enable intl bcmath pcntl opcache pdo_mysql pdo_pgsql redis swoole ldap zip soap gd

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer


FROM alpine:3.15

RUN set -xe \
    && apk add --update --no-cache tzdata bash zip unzip \
        readline libxml2 libcurl oniguruma argon2-libs sqlite-libs libpng libldap libzip \
        libgcc icu-libs libpq libsodium libstdc++ \
		libxrender fontconfig freetype libx11 \
    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && rm -rf /tmp/* /var/tmp/* /usr/local/lib/php/doc/* /var/cache/apk/* /var/log/lastlog /var/log/faillog \
    && rm -rf *.tgz *.tar *.zip

COPY --from=build /usr/local/etc/php/php.ini /usr/local/etc/php/php.ini
COPY --from=build /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d
COPY --from=build /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=build /usr/local/bin/php /usr/local/bin/
COPY --from=build /usr/bin/composer /usr/bin/composer

# ensure www-data user exists
RUN set -eux; \
    adduser -u 82 -D -S -G www-data www-data
# 82 is the standard uid/gid for "www-data" in Alpine

RUN set -eux; \
    [ ! -d /var/www/html ]; \
    mkdir -p /var/www/html; \
    chown www-data:www-data /var/www/html; \
    chmod 777 /var/www/html

WORKDIR /var/www/html

COPY ./config/php/*.ini /usr/local/etc/php/conf.d/
COPY ./src/docker-entrypoint-init.d /docker-entrypoint-init.d
COPY ./src/runtimes/ /usr/local/bin/runtimes/
COPY ./src/start-container.sh /usr/local/bin/start-container.sh

RUN chmod +x /usr/local/bin/start-container.sh /usr/local/bin/runtimes/*.sh

EXPOSE 80

ENTRYPOINT ["start-container.sh"]