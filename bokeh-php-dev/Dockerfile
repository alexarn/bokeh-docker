FROM afi-php-7.1-dev:latest
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV uid=500
ENV install_dir=www

COPY php.ini /usr/local/etc/php/php.ini
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY bokeh-php-fpm.conf /tmp/bokeh-php-fpm.conf
COPY bokeh-pool.conf /tmp/bokeh-pool.conf
COPY install-util.sh /tmp/install-util.sh
COPY init-php.sh /tmp/init-php.sh
COPY start-php.sh /start-php.sh

EXPOSE 9000

ENTRYPOINT ["bash", "/start-php.sh"]
