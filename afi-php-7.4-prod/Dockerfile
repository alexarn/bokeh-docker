FROM php:7.4-fpm-buster
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils apt-transport-https
RUN apt-get install -y --no-install-recommends curl wget iputils-ping dnsutils lsb-release vim sudo rsync tzdata locales openssl libapr1-dev libssl-dev procps

RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

RUN sed -i '/fr_FR\.UTF/s/^# //g' /etc/locale.gen \
    && sed -i '/en_US\.UTF/s/^# //g' /etc/locale.gen \
    && locale-gen
ENV LANG fr_FR.UTF-8

RUN apt-get update -yqq \
    && apt-get install locales \
               libfreetype6-dev \
               libjpeg62-turbo-dev \
               libpng-dev \
               libmcrypt-dev \
               imagemagick \
               libmagickwand-dev \
               libfontconfig \
               bzip2 \
	       libmemcached-dev \
	       zlib1g-dev \
               yaz \
               default-mysql-client \
	       zip \
	       libzip-dev \
	       libxslt-dev \
               git -yqq

RUN pecl install imagick-3.4.3RC1 \
    && pecl install memcached \
    && pecl install mcrypt-1.0.3

RUN docker-php-ext-enable imagick \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable opcache \
    && docker-php-ext-enable mcrypt

RUN docker-php-ext-install pcntl

RUN docker-php-ext-configure zip \
    && docker-php-ext-install mysqli gettext calendar zip soap xsl \
    && docker-php-ext-install -j$(nproc) iconv

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

RUN apt-get install -y --no-install-recommends graphviz \
    && apt-get -y autoclean && apt-get -y clean

RUN addgroup --system --gid 500 webmaster \
    && adduser --system --home /home/webmaster --shell /bin/bash --disabled-password --gid 500 --uid 500 webmaster \
    && usermod -G webmaster www-data \
    && usermod -G www-data webmaster

RUN mkdir /usr/local/lib/php/sessions \
    && chmod g-rs /usr/local/lib/php/sessions && chmod o-rx /usr/local/lib/php/sessions \
    && chmod g+wx /usr/local/lib/php/sessions && chmod o+wt /usr/local/lib/php/sessions \
    && chown webmaster:www-data /usr/local/lib/php/sessions

EXPOSE 9000

CMD ["php-fpm", "-F"]
