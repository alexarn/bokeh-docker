#!/bin/bash

function main {
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
		cp /tmp/install-util.sh /home/webmaster/${install_dir}/php/
		chown webmaster:webmaster /home/webmaster/${install_dir}/php/*.sh
	fi

	if [ -z "$(ls -A /home/webmaster/${install_dir}/php/bokeh)" ]
	then
		echo "[BOKEH-PHP] Install source tree..."
		cd /home/webmaster/${install_dir}/php/bokeh
		git clone https://git.afi-sa.net/afi/opacce.git .
	fi

	cd /home/webmaster/${install_dir}/php/bokeh
	source /home/webmaster/${install_dir}/php/install-util.sh
	nextStep "git reset --hard HEAD"
	executeCommand "git reset --hard HEAD"
	nextStep "git fetch -t --all"
	executeCommand "git fetch -t --all"
	nextStep "git checkout $(git describe --tags)"
	executeCommand "git checkout $(git describe --tags)"
	nextStep "./update.sh"
	executeCommand "./update.sh"
}

install_dir=$1
main
