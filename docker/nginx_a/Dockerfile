FROM alpine:latest

ARG PHP_VERSION=83

ENV ADMINER_VERSION=4.8.1

ENV PHP_VERSION ${PHP_VERSION}

# ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN echo "Asia/Hong_kong" > /etc/timezone

RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

RUN \
  # prepare
  # echo @legacy https://dl-cdn.alpinelinux.org/alpine/v3.19/community >> /etc/apk/repositories \
  # install
  apk add -U --no-cache \
    curl \
    wget \
    git \
    openrc \
    npm \
    nano \
    nginx \
    redis \
    openssl \
    # build-base \
    libbz2 \
    supervisor

RUN apk add --no-cache php${PHP_VERSION} \
      php${PHP_VERSION}-fpm \
      php${PHP_VERSION}-bcmath \
      php${PHP_VERSION}-bz2 \
      php${PHP_VERSION}-ctype \
      php${PHP_VERSION}-curl \
      php${PHP_VERSION}-dom \
      php${PHP_VERSION}-fileinfo \
      # php${PHP_VERSION}-filter \
      php${PHP_VERSION}-gd \
      # php${PHP_VERSION}-hash \
      php${PHP_VERSION}-iconv \
      php${PHP_VERSION}-intl \
      php${PHP_VERSION}-json \
      # php${PHP_VERSION}-libxml \
      php${PHP_VERSION}-mbstring \
      php${PHP_VERSION}-mysqli \
      php${PHP_VERSION}-openssl \
      php${PHP_VERSION}-phar \
      # php${PHP_VERSION}-pcre \
      php${PHP_VERSION}-pdo_mysql \
      php${PHP_VERSION}-simplexml \
      php${PHP_VERSION}-soap \
      php${PHP_VERSION}-sockets \
      php${PHP_VERSION}-session \
      php${PHP_VERSION}-sodium \
      # php${PHP_VERSION}-spl \
      php${PHP_VERSION}-tokenizer  \
      php${PHP_VERSION}-xmlwriter \
      php${PHP_VERSION}-xsl \
      php${PHP_VERSION}-zip \
      php${PHP_VERSION}-zlib \
      php${PHP_VERSION}-xml \
      php${PHP_VERSION}-dev \
      # php${PHP_VERSION}-imagick  \
      php${PHP_VERSION}-tidy  \
      # php${PHP_VERSION}-xmlrpc \
      php${PHP_VERSION}-common  \
      php${PHP_VERSION}-cli  \
      php${PHP_VERSION}-opcache  \
      php${PHP_VERSION}-redis

# RUN ln -s /usr/bin/php${PHP_VERSION} /usr/bin/php

# VOLUME /sys/fs/cgroup
# # RUN rc-update add php-fpm${PHP_VERSION} default\
# RUN mkdir /run/openrc\
#   && touch /run/openrc/softlevel

# RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
#     && pecl install uploadprogress \
#     && docker-php-ext-enable uploadprogress \
#     && apk del .build-deps $PHPIZE_DEPS \
#     && chmod uga+x /usr/local/bin/install-php-extensions && sync \
#     && install-php-extensions bcmath \
#                       ctype \
#                       curl \
#                       dom \
#                       fileinfo \
#                       filter \
#                       gd \
#                       hash \
#                       iconv \
#                       intl \
#                       json \
#                       libxml \
#                       mbstring \
#                       mysqli \
#                       openssl \
#                       pcre \
#                       pdo_mysql \
#                       simplexml \
#                       soap \
#                       sockets \
#                       session \
#                       sodium \
#                       spl \
#                       tokenizer  \
#                       xmlwriter \
#                       xsl \
#                       zip \
#                       zlib \
#                       xml
# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

RUN \
  # adminer
  # mkdir -p /var/www/adminer \
  #   && curl -sSLo /var/www/adminer/index.php \
  #     "https://github.com/vrana/adminer/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION-en.php" \
  # cleanup
  # && \
  rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

# Installing phpMyAdmin
RUN cd /var/www \
    && wget -c "https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz" \
    && tar -zxvf phpMyAdmin-5.2.1-all-languages.tar.gz && mv phpMyAdmin-5.2.1-all-languages pma \
    && rm -rf phpMyAdmin-5.2.1-all-languages.tar.gz;

COPY config/phpmyadmin/config.inc.php /var/www/pma/config.inc.php
# COPY config/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
# nginx config
# RUN rm -rf /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*

RUN wget https://artifacts.opensearch.org/releases/bundle/opensearch/2.19.1/opensearch-2.19.1-linux-x64.tar.gz
RUN tar -xzf opensearch-2.19.1-linux-x64.tar.gz
RUN cd opensearch-2.19.1 \ bin/opensearch-service enable

RUN env OPENSEARCH_INITIAL_ADMIN_PASSWORD=My#Admin@123

RUN rm -rf /etc/php${PHP_VERSION}/php-fpm.d/*
COPY config/php/pool.d/ /etc/php${PHP_VERSION}/php-fpm.d/

RUN rm -rf /etc/nginx/nginx.conf
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf

RUN rm -rf /etc/nginx/conf.d/*
COPY config/nginx/default.template.conf /etc/nginx/conf.d/01_default.conf
# COPY config/conf.d/default.conf /etc/nginx/conf.d/default.conf
# COPY nginx/default.template.conf /etc/nginx/conf.d/01_default.conf
COPY src/. /var/www/html/
# COPY php/pool.d/ /etc/php//fpm/pool.d/

# RUN ln -s /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

RUN chown -R www-data:www-data /var/www

RUN sed -i "s/Php8.0/php${PHP_VERSION}/g" /var/www/html/src/views/index.php
# supervisor config
COPY \
  config/supervisor/nginx.ini \
  # pgsql/pgsql.ini \
  config/supervisor/php-fpm.ini \
  # rabbitmq/rabbitmq.ini \
  config/supervisor/redis.ini \
  /etc/supervisor.d/

RUN sed -i "s/@phpver/${PHP_VERSION}/g" /etc/supervisor.d/php-fpm.ini

# entrypoint
# COPY docker-entrypoint.sh /docker-entrypoint.sh
# RUN chmod +x /docker-entrypoint.sh

# ports
EXPOSE 8000 6001 5173 80 5001

# COPY startup.sh .
# RUN chmod +x ./startup.sh
# ENTRYPOINT ["./startup.sh"]
# commands
# ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["/bin/sh", "-c", "/etc/init.d/php-fpm stop && update-rc.d php-fpm defaults && /etc/init.d/php-fpm start && nginx -g 'daemon off;'"]
# CMD ["supervisord", "-n", "-j", "/supervisord.pid", "nginx", "-g", "'daemon off;'"]
# ENTRYPOINT ["./startup.sh"]
# CMD ["/bin/sh", "-c", "supervisord -n -j /supervisord.pid && nginx -g 'daemon off;'"]
# USER www-data
CMD ["supervisord", "-n", "-j", "/supervisord.pid"]
