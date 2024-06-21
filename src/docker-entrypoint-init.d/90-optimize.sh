#!/bin/bash

if [[ $IS_SERVING == true ]]; then
    php artisan optimize:clear
    php artisan optimize
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    php artisan event:cache
    php artisan storage:link
fi
