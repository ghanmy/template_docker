FROM php:7.4-fpm

LABEL maintainer="Ghanmy Mohsen <ghanmy@mobiblanc.com>"

# Common
RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    apt-get install -yqq \
      apt-utils \
      gnupg2 \
      git \
      libzip-dev zip unzip && \
      docker-php-ext-configure zip && \
      # Install the zip extension
      docker-php-ext-install zip && \
      php -m | grep -q 'zip'

RUN apt-get update && apt-get install -y --no-install-recommends \
        zlib1g-dev \
        libxml2-dev \
        libzip-dev \
    && docker-php-ext-install \
        intl \
        opcache \
		mysqli \
        pdo pdo_mysql

# wkhtmltopdf
RUN apt-get install -yqq \
      libxrender1 \
      libfontconfig1 \
      libx11-dev \
      libjpeg62 \
      libxtst6 \
      fontconfig \
      libjpeg62-turbo \
      xfonts-base \
      xfonts-75dpi \
      wget \
    && wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.stretch_amd64.deb \
    && dpkg -i wkhtmltox_0.12.6-1.stretch_amd64.deb \
    && apt -f install

#Install Cron
RUN apt-get update
RUN apt-get -y install cron


# images
RUN apt-get update \
	&& apt-get install -y \
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libpng-dev \
	libgd-dev \
	&& docker-php-ext-install soap \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) \
		gd \
		exif
# LDAP
RUN \
    apt-get update && \
    apt-get install libldap2-dev -y && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

# strings
RUN apt-get update \
    && apt-get install -y libonig-dev \
    && docker-php-ext-install -j$(nproc) \
	    gettext \
	    mbstring

# PECL

###########################################################################
# APCU:
###########################################################################
RUN pecl install apcu \
    docker-php-ext-enable apcu

###########################################################################
# xDebug:
###########################################################################
#RUN pecl install xdebug \
#    docker-php-ext-enable xdebug



# install composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN set -eux; \
	{ \
		echo '[www]'; \
		echo 'ping.path = /ping'; \
	} | tee /usr/local/etc/php-fpm.d/docker-healthcheck.conf
RUN set -eux; \
	composer clear-cache
# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1

## NodeJS, NPM

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y yarn

COPY ../ /var/www/symfony

# Add default configuration files
COPY php-fpm /usr/local/etc/php/conf.d


WORKDIR /var/www/symfony



COPY docker-entrypoint.sh docker/docker-entrypoint.sh

RUN chmod +x /var/www/symfony/docker/docker-entrypoint.sh

ENTRYPOINT ["/var/www/symfony/docker/docker-entrypoint.sh"]

RUN rm -rf var/cache

RUN rm -rf var/log

RUN mkdir -p var/log var/cache


RUN chmod -R 777 var

#
#--------------------------------------------------------------------------
# Final Touch
#--------------------------------------------------------------------------
#

# Clean
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

RUN groupmod -o -g 1000 www-data && \
    usermod -o -u 1000 -g www-data www-data

CMD ["php-fpm", "-F"]

EXPOSE 9003

