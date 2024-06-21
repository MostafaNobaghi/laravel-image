#!/bin/bash

if [[ $IS_SERVING == true ]]; then
    /usr/local/bin/runtimes/${SERVING_MODE:-artisan}.sh
fi
