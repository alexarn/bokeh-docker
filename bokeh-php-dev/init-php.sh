#!/bin/bash

function ensure_directories {
    if [ ! -d /home/webmaster/${install_dir} ]
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
    nextStep "git fetch -t --all"
    executeCommand "git fetch -t --all"
    nextStep "./update.sh"
    executeCommand "./update.sh"
}


function ensure_confs {
    if [ -z "$(ls -A /home/webmaster/${install_dir}/conf/php)" ]
    then
        echo "[BOKEH-PHP] Install PHP conf files..."
        cp -p /tmp/bokeh-php-fpm.conf /home/webmaster/${install_dir}/conf/php/
        cp -p /tmp/bokeh-pool.conf /home/webmaster/${install_dir}/conf/php/
        sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/bokeh-php-fpm.conf
        sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/php/bokeh-pool.conf
    fi

    if [ ! -a /home/webmaster/${install_dir}/php/bokeh/local.php ]
    then
	cp /tmp/local.php /home/webmaster/${install_dir}/php/bokeh/
	chown webmaster:webmaster /home/webmaster/${install_dir}/php/bokeh/local.php
    fi
    
    if [ "${memcache_host}" == "none" ]
    then
        cp /tmp/session_save_path.dir /home/webmaster/${install_dir}/conf/php/session_save_path.conf
        sed -i "s:^define('MEMCACHED://define('MEMCACHED:g" /home/webmaster/${install_dir}/php/bokeh/local.php
    else
        cp /tmp/session_save_path.memcache /home/webmaster/${install_dir}/conf/php/session_save_path.conf
        sed -i "s:MEMCACHEHOST:${memcache_host}:g" /home/webmaster/${install_dir}/conf/php/session_save_path.conf
        sed -i "s:MEMCACHEHOST:${memcache_host}:g" /home/webmaster/${install_dir}/php/bokeh/local.php
    fi
}


install_dir=$1

ensure_directories
ensure_install_utils
ensure_bokeh_sources
ensure_confs    

