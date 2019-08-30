#!/bin/bash

function main {
	usermod -u ${uid} webmaster && groupmod -g ${uid} webmaster
	chown webmaster:www-data /usr/local/lib/php/sessions
	su -l webmaster -c "bash /tmp/init-php.sh ${install_dir}"

	if [ -z "$(ls -A /home/webmaster/${install_dir}/conf/php)" ]
	then
		echo "[BOKEH-PHP] Install PHP conf files..."
		cp -p /tmp/bokeh-php-fpm.conf /home/webmaster/${install_dir}/conf/php/
		cp -p /tmp/bokeh-pool.conf /home/webmaster/${install_dir}/conf/php/
		sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/bokeh-php-fpm.conf
		sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/bokeh-pool.conf
	fi

	if [ "${memcache_host}" == "none" ]
	then
		cp /tmp/session_save_path.dir /home/webmaster/${install_dir}/conf/php/session_save_path.conf
		cp /tmp/local.php /home/webmaster/${install_dir}/php/bokeh/
		chown webmaster:webmaster /home/webmaster/${install_dir}/php/bokeh/local.php
		sed -i "s:^define('MEMCACHED://define('MEMCACHED:g" /home/webmaster/${install_dir}/php/bokeh/local.php
	else
		cp /tmp/session_save_path.memcache /home/webmaster/${install_dir}/conf/php/session_save_path.conf
		sed -i "s:MEMCACHEHOST:${memcache_host}:g" /home/webmaster/${install_dir}/conf/php/session_save_path.conf
		cp /tmp/local.php /home/webmaster/${install_dir}/php/bokeh/
		chown webmaster:webmaster /home/webmaster/${install_dir}/php/bokeh/local.php
		sed -i "s:MEMCACHEHOST:${memcache_host}:g" /home/webmaster/${install_dir}/php/bokeh/local.php
	fi

	sed -i "s:INSTALLDIR:${install_dir}:g" /usr/local/etc/php/php.ini
	sed -i "s:INSTALLDIR:${install_dir}:g" /usr/local/etc/php-fpm.conf

	echo "[BOKEH-PHP] Start php-fpm..."
	php-fpm -F
}

main
