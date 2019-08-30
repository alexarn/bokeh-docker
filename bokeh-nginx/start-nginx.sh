#!/bin/bash

function main {
	usermod -u ${uid} webmaster && groupmod -g ${uid} webmaster
	chown webmaster:webmaster /tmp/*.sql
	php_ip=$(dig +short ${php_host})
	#net_gw=$(route -n | grep ^0.0.0.0 |awk '{print $2}')
        #su -l webmaster -c "bash /tmp/init-site.sh ${install_dir} ${url} ${MYSQL_ROOT_PASSWORD} ${db_host} ${db_name} ${db_user} ${db_pwd} ${php_host} ${php_ip} ${net_gw}"
        su -l webmaster -c "bash /tmp/init-site.sh ${install_dir} ${url} ${MYSQL_ROOT_PASSWORD} ${db_host} ${db_name} ${db_user} ${db_pwd} ${php_host} ${php_ip}"

        if [ -z "$(ls -A /home/webmaster/${install_dir}/conf/nginx)" ]
        then
                echo "[BOKEH-NGINX] Install NGINX conf files..."
                cp -p /tmp/bokeh.inc /home/webmaster/${install_dir}/conf/nginx/
                cp -p /tmp/site.conf /home/webmaster/${install_dir}/conf/nginx/
                sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/nginx/bokeh.inc
		sed -i "s:PHPHOST:${php_host}:g" /home/webmaster/${install_dir}/conf/nginx/bokeh.inc
                sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/nginx/site.conf
		sed -i "s:BOKEH_URL:${url}:g" /home/webmaster/${install_dir}/conf/nginx/site.conf
		sed -i "s:INSTALLDIR:${install_dir}:g" /etc/nginx/nginx.conf
	else
		echo "[BOKEH-NGINX] Set NGINX conf files..."
		sed -i "s:INSTALLDIR:${install_dir}:g" /etc/nginx/nginx.conf
        fi

        echo "[BOKEH-NGINX] Start nginx..."
        nginx -g "daemon off;"
}

main
