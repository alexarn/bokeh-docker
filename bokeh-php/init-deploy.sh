#!/bin/bash

function main {
	if [ ! -d /home/webmaster/${install_dir} ]
	then
		echo "[BOKEH-PHP] Create bokeh subtree..."
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/php/bokeh"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/conf/php"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/conf/mysql"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/conf/nginx"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/log/php"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/log/nginx"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/log/mysql"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/htdocs"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/ftp"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/mysql"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/scripts"
		su -l webmaster -c "mkdir -p /home/webmaster/${install_dir}/temp"
		su -l webmaster -c "chmod 777 /home/webmaster/${install_dir}/temp"
		mv /tmp/*.sh /home/webmaster/${install_dir}/php/
		chown webmaster:webmaster /home/webmaster/${install_dir}/php/*.sh
	fi

	if [ -z "$(ls -A /home/webmaster/${install_dir}/conf/php)" ]
	then
		echo "[BOKEH-PHP] Install PHP conf files..."
		mv /tmp/bokeh-php-fpm.conf /home/webmaster/${install_dir}/conf/php/
		mv /tmp/bokeh-pool.conf /home/webmaster/${install_dir}/conf/php/
		sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/bokeh-php-fpm.conf
		sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/bokeh-pool.conf
	fi

	if [ -z "$(ls -A /home/webmaster/${install_dir}/php/bokeh)" ]
	then
		echo "[BOKEH-PHP] Install source tree..."
		su -l webmaster -c "cd /home/webmaster/${install_dir}/php/bokeh; git clone https://git.afi-sa.net/afi/opacce.git .;"
	fi

	su -l webmaster -c "cd /home/webmaster/${install_dir}/php/bokeh; git reset --hard HEAD; git fetch -t --all; git checkout $(git describe --tags); ./update.sh"

	sed -i "s:INSTALLDIR:${install_dir}:g" /usr/local/etc/php/php.ini
	sed -i "s:INSTALLDIR:${install_dir}:g" /usr/local/etc/php-fpm.conf

	php-fpm -F
}

main
