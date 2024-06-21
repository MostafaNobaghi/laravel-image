# Laravel Dockerize

## Usage

create _Dockerfile_

```Dockerfile
# change BASE_ADDRESS with your repository address
FROM ${BASE_ADDRESS}/laravel:php8.1.2

USER app

COPY composer* ./

RUN COMPOSER_MEMORY_LIMIT=-1 composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --ignore-platform-reqs \
    --optimize-autoloader \
    --apcu-autoloader \
    --ansi \
    --no-scripts;

COPY --chown=app:app . ./

RUN composer run-script post-autoload-dump && composer run-script post-update-cmd

```

create _docker-compose.yaml_

```yaml
version: "3"
services:
  production.app:
    build:
      context: ./
      dockerfile: Dockerfile
    ports:
      - "${APP_PORT:-8000}:80"
    env_file:
      - .env.production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/"]
      retries: 3
      timeout: 10s
```

enjoy!

## Environments

The following environment variables can be used :

- `APP_DEBUG` _false_:
- `SERVING_MODE` _artisan_: can be [artisan, octane].
- `OCTANE_SERVER` _swoole_:
- `OCTANE_MAX_REQUESTS` _500_:
