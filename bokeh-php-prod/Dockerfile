FROM afi-php-7.4-prod:latest
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV uid=500
ENV install_dir=www
ENV memcache_host=none

COPY php.ini /usr/local/etc/php/php.ini
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY bokeh-php-fpm.conf /tmp/bokeh-php-fpm.conf
COPY bokeh-pool.conf /tmp/bokeh-pool.conf
COPY memcached_tuning.conf /tmp/memcached_tuning.conf
COPY opcache_tuning.conf /tmp/opcache_tuning.conf
COPY session_save_path.memcache /tmp/session_save_path.memcache
COPY session_save_path.dir /tmp/session_save_path.dir
COPY local.php /tmp/local.php
COPY install-util.sh /tmp/install-util.sh
COPY init-php.sh /tmp/init-php.sh
COPY start-php.sh /start-php.sh
COPY wait /wait
RUN chmod +x /wait

EXPOSE 9000

CMD /wait && bash /start-php.sh
