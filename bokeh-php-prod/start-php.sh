#!/bin/bash

function main {
    php_host=$(hostname -s)
    sed -i "s:INSTALLDIR:${install_dir}:g" /usr/local/etc/php/php.ini
    sed -i "s:PHPHOST:${php_host}:g" /usr/local/etc/php/php.ini
    sed -i "s:INSTALLDIR:${install_dir}:g" /usr/local/etc/php-fpm.conf
    sed -i "s:PHPHOST:${php_host}:g" /usr/local/etc/php-fpm.conf
    
    usermod -u ${uid} webmaster && groupmod -g ${uid} webmaster
    chown webmaster:www-data /usr/local/lib/php/sessions
    chown webmaster:webmaster /tmp/*.conf
    su -l webmaster -c "bash /tmp/init-php.sh ${install_dir} ${memcache_host} ${php_host}"

    echo "[BOKEH-PHP] Start php-fpm..."
    php-fpm -F
}

main
