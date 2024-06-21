#!/bin/bash

php -d variables_order=EGPCS /var/www/html/artisan octane:start \
    --server=${OCTANE_SERVER:-swoole} \
    --host=0.0.0.0 \
    --port=80 \
    --max-requests=${OCTANE_MAX_REQUESTS:-500}
