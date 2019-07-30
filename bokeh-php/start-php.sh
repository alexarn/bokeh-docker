#!/bin/bash

function main {
	su -l webmaster -c "bash /tmp/init-php.sh ${install_dir}"

	if [ -z "$(ls -A /home/webmaster/${install_dir}/conf/php)" ]
	then
		echo "[BOKEH-PHP] Install PHP conf files..."
		cp -p /tmp/bokeh-php-fpm.conf /home/webmaster/${install_dir}/conf/php/
		cp -p /tmp/bokeh-pool.conf /home/webmaster/${install_dir}/conf/php/
		sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/bokeh-php-fpm.conf
		sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/bokeh-pool.conf
	fi

	sed -i "s:INSTALLDIR:${install_dir}:g" /usr/local/etc/php/php.ini
	sed -i "s:INSTALLDIR:${install_dir}:g" /usr/local/etc/php-fpm.conf

	echo "[BOKEH-PHP] Start php-fpm..."
	php-fpm -F
}

main
