# syntax=docker/dockerfile:1
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --no-progress --prefer-dist \
    --no-scripts --no-autoloader --ignore-platform-reqs
COPY . .
RUN composer dump-autoload --no-dev --optimize --classmap-authoritative --no-scripts

FROM php:8.3-fpm-alpine AS runtime
COPY --from=ghcr.io/mlocati/php-extensions-installer:latest /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_pgsql pgsql mbstring zip gd bcmath opcache mongodb \
 && rm /usr/local/bin/install-php-extensions \
 && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
 && printf 'expose_php=Off\ndisplay_errors=Off\nopcache.validate_timestamps=0\nopcache.memory_consumption=64\n' > "$PHP_INI_DIR/conf.d/zz-habitta.ini" \
 && printf '[global]\nerror_log = /proc/self/fd/2\n[www]\nlisten = 127.0.0.1:9000\nclear_env = no\ncatch_workers_output = yes\ndecorate_workers_output = no\npm = dynamic\npm.max_children = 4\npm.start_servers = 2\npm.min_spare_servers = 1\npm.max_spare_servers = 3\n' > /usr/local/etc/php-fpm.d/zz-habitta.conf
WORKDIR /var/www/html
COPY --from=vendor --chown=www-data:www-data /app/ ./
RUN chown -R www-data:www-data storage bootstrap/cache
USER www-data
EXPOSE 9000
ENTRYPOINT ["./docker-entrypoint.sh"]
