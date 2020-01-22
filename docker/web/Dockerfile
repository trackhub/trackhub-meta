# Build the base image
FROM debian:9 AS trackhub-base

RUN apt-get update && \
    apt-get install -y apache2 apt-transport-https netcat unzip wget && \
    rm -rf /var/lib/apt/lists/*

# Configure Apache2 server
COPY virtualhost.conf /etc/apache2/sites-enabled/000-default.conf
COPY virtualhost-ssl.conf /etc/apache2/sites-available/000-default-ssl.conf

RUN a2enmod rewrite ssl expires

# Install PHP
ENV PHP_V="7.4"
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list

RUN apt-get update && \
    apt-get install -y php${PHP_V} \
                       php${PHP_V}-mysql \
                       php${PHP_V}-xml \
                       php${PHP_V}-curl \
                       php${PHP_V}-mbstring \
                       php${PHP_V}-imagick \
                       php${PHP_V}-exif \
                       php${PHP_V}-intl && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set php /usr/bin/php${PHP_V}
COPY php.ini /etc/php/${PHP_V}/apache2/php.ini

# Install composer
RUN wget https://getcomposer.org/composer-stable.phar -O /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

WORKDIR /var/www

# Build the development image
FROM trackhub-base AS trackhub-dev

RUN a2ensite 000-default-ssl

COPY cert/server.key /etc/ssl/private/apache.key
COPY cert/server.crt /etc/ssl/certs/apache.crt

RUN apt-get update && \
    apt-get install -y php${PHP_V}-xdebug && \
    rm -rf /var/lib/apt/lists/*

COPY xdebug.ini /etc/php/${PHP_V}/apache2/conf.d/20-xdebug.ini
COPY xdebug.ini /etc/php/${PHP_V}/cli/conf.d/20-xdebug.ini
COPY entrypoint.sh /entrypoint.sh

CMD /bin/bash /entrypoint.sh

# Build the production image
FROM trackhub-base AS trackhub-prod
#CMD usermod -u $WEB_UID www-data && \
#    su www-data bash -c "cd /var/www/script/migration && composer install --no-dev && ./vendor/bin/phinx migrate" && \
#    su www-data bash -c "export APP_ENV=prod && composer install -d /var/www --no-dev -o" && \
#    su www-data -s /bin/bash -c "cd /var/www && yarn install" && \
#    su www-data -s /bin/bash -c "cd /var/www && yarn encore production" && \
#    apachectl -D FOREGROUND
CMD apachectl -D FOREGROUND