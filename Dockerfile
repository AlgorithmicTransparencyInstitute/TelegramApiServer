FROM arm64v8/php:8.0-cli

RUN apt-get update && apt-get upgrade -y \
    && apt-get install apt-utils procps -y \
    # Install main extension
    && apt-get install git zip vim libzip-dev libgmp-dev libevent-dev libssl-dev libnghttp2-dev libffi-dev -y \
    && docker-php-ext-install -j$(nproc) sockets zip gmp pcntl bcmath ffi mysqli pdo pdo_mysql \
    # Install additional extension
    && mkdir -p /usr/src/php/ext/ && cd /usr/src/php/ext/ \
    && pecl bundle ev \
    && docker-php-ext-install -j$(nproc) ev \
    # Install composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    # Cleanup
    && docker-php-source delete \
    && apt-get autoremove --purge -y && apt-get autoclean -y && apt-get clean -y \
    && rm -rf /usr/src

COPY . /app
WORKDIR /app

RUN cp -a docker/php/conf.d/. "$PHP_INI_DIR/conf.d/" \
    && composer install -o --no-dev \
    && composer clear

#Creating symlink to save .env in volume
RUN mkdir -p /app/sessions &&  \
    touch '/app/sessions/.env.docker' && \
    ln -s '/app/sessions/.env.docker' '/app/.env.docker'

VOLUME ["/app/sessions"]

EXPOSE 9503

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-arm64 /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# Run your program under Tini
CMD ["php", "server.php", "-e=.env.docker", "--docker", "-s=*", "--session=www"]
