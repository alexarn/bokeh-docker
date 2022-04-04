FROM php:8.1-fpm-buster
MAINTAINER AFI SA - Bokeh Team <dev-opac@afi-sa.fr>

ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils apt-transport-https
RUN apt-get install -y --no-install-recommends curl wget iputils-ping dnsutils lsb-release vim sudo rsync tzdata locales openssl libapr1-dev libssl-dev

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

RUN pecl install imagick-3.7.0 \
    && pecl install memcached \
    && pecl install xdebug

RUN pecl install -n mcrypt

RUN cd /root && git clone "https://github.com/longxinH/xhprof" && cd xhprof/extension/ \
    && phpize \
    && ./configure \
    && make \
    && make install

RUN docker-php-ext-enable memcached \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable opcache \
    && docker-php-ext-enable xhprof \
    && docker-php-ext-enable imagick

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

RUN cd /usr/local/src \
    && git clone https://git.afi-sa.net/afi/phpunit.git \
    && cd phpunit \
    && git checkout bokeh-81

COPY phpunit /usr/local/bin/phpunit

RUN chmod +x /usr/local/bin/phpunit

RUN cd /usr/local/share \
    && wget -O chrome-linux.zip https://download-chromium.appspot.com/dl/Linux_x64?type=snapshots \
    && unzip chrome-linux.zip \
    && ln -s /usr/local/share/chrome-linux/chrome /usr/local/bin/chromium \
    && apt-get install -yqq  libnss3 \
			     libatk1.0-0 \
			     libatk-bridge2.0-0 \
			     libdrm2 \
			     libxkbcommon0 \
			     libxcomposite1 \
			     libxdamage1 \
			     libxrandr2 \
			     libgbm1 \
			     libasound2 \
			     libxshmfence1
    
EXPOSE 9000

CMD ["php-fpm", "-F"]
