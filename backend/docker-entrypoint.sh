#!/bin/sh
set -e
mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache
php artisan config:cache
php artisan route:cache || true
php artisan view:cache || true
exec php-fpm
