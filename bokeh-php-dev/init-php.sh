#!/bin/bash

function ensure_directories {
    if [ ! -d /home/webmaster/${install_dir} ] || [ -z "$(ls -A /home/webmaster/${install_dir})" ]
    then
	echo "[BOKEH-PHP] Create bokeh subtree..."
	mkdir -p /home/webmaster/${install_dir}/php/bokeh
	mkdir -p /home/webmaster/${install_dir}/conf/php
	mkdir -p /home/webmaster/${install_dir}/conf/mysql
	mkdir -p /home/webmaster/${install_dir}/conf/nginx
	mkdir -p /home/webmaster/${install_dir}/log/php
	mkdir -p /home/webmaster/${install_dir}/log/nginx
	mkdir -p /home/webmaster/${install_dir}/log/mysql
	mkdir -p /home/webmaster/${install_dir}/htdocs
	mkdir -p /home/webmaster/${install_dir}/ftp
	mkdir -p /home/webmaster/${install_dir}/mysql
	mkdir -p /home/webmaster/${install_dir}/scripts
	mkdir -p /home/webmaster/${install_dir}/temp
	chmod 777 /home/webmaster/${install_dir}/temp
    fi
}


function ensure_install_utils {
    if [ ! -a /home/webmaster/${install_dir}/php/install-util.sh ]
    then
        cp /tmp/install-util.sh /home/webmaster/${install_dir}/php/
        chown webmaster:webmaster /home/webmaster/${install_dir}/php/*.sh
    fi
    source /home/webmaster/${install_dir}/php/install-util.sh
}


function ensure_bokeh_sources {
    if [ -z "$(ls -A /home/webmaster/${install_dir}/php/bokeh)" ]
    then
        nextStep "[BOKEH-PHP] Install source tree..."
        cd /home/webmaster/${install_dir}/php/bokeh
	git clone https://git.afi-sa.net/afi/opacce.git .
    fi

    cd /home/webmaster/${install_dir}/php/bokeh
    nextStep "./update.sh"
    executeCommand "./update.sh"
}


function ensure_confs {
    if [ ! -f /home/webmaster/${install_dir}/conf/php/${php_host}-bokeh-php-fpm.conf ]
    then
	echo "[BOKEH-PHP] Install PHP conf file ${php_host}-bokeh-php-fpm.conf..."
	cp -p /tmp/bokeh-php-fpm.conf /home/webmaster/${install_dir}/conf/php/${php_host}-bokeh-php-fpm.conf
	sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/${php_host}-bokeh-php-fpm.conf
	sed -i "s:PHPHOST:${php_host}:g" /home/webmaster/${install_dir}/conf/php/${php_host}-bokeh-php-fpm.conf
    fi

    if [ ! -f /home/webmaster/${install_dir}/conf/php/${php_host}-bokeh-pool.conf ]
    then
	echo "[BOKEH-PHP] Install PHP conf file ${php_host}-bokeh-pool.conf..."
	cp -p /tmp/bokeh-pool.conf /home/webmaster/${install_dir}/conf/php/${php_host}-bokeh-pool.conf
	cp -p /tmp/opcache_tuning.conf /home/webmaster/${install_dir}/conf/php/opcache_tuning.conf
	sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/${php_host}-bokeh-pool.conf
	sed -i "s:PHPHOST:${php_host}:g" /home/webmaster/${install_dir}/conf/php/${php_host}-bokeh-pool.conf
    fi

    if [ ! -f /home/webmaster/${install_dir}/php/bokeh/local.php ]
    then
	echo "[BOKEH-PHP] Copy local.php conf file..."
	cp /tmp/local.php /home/webmaster/${install_dir}/php/bokeh/
	chown webmaster:webmaster /home/webmaster/${install_dir}/php/bokeh/local.php
    fi
    
    if [ "${memcache_host}" == "none" ]
    then
	echo "[BOKEH-PHP] Disable PHP memcached server configuration..."
	mkdir /home/webmaster/${install_dir}/php/sessions
	chown webmaster:www-data /home/webmaster/${install_dir}/php/sessions
	chmod 1732 /home/webmaster/${install_dir}/php/sessions
        cp /tmp/session_save_path.dir /home/webmaster/${install_dir}/conf/php/session_save_path.conf
	sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/session_save_path.conf
    else
	echo "[BOKEH-PHP] Enable PHP memcached server configuration..."
        cp /tmp/session_save_path.memcache /home/webmaster/${install_dir}/conf/php/session_save_path.conf
        cp /tmp/memcached_tuning.conf /home/webmaster/${install_dir}/conf/php/memcached_tuning.conf
        sed -i "s:MEMCACHEHOST:${memcache_host}:g" /home/webmaster/${install_dir}/conf/php/session_save_path.conf
        sed -i "s:MEMCACHEHOST:${memcache_host}:g" /home/webmaster/${install_dir}/php/bokeh/local.php
    fi
}


install_dir=$1
memcache_host=$2
php_host=$3

ensure_directories
ensure_install_utils
ensure_bokeh_sources
ensure_confs    

