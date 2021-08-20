#!/bin/bash

function main {
	usermod -u ${uid} webmaster && groupmod -g ${uid} webmaster
	chown webmaster:webmaster /tmp/*.sql /tmp/*.conf /tmp/*.inc
	local_host=$(hostname -s)
	php_ip=$(dig +short ${php_host})
	php_net=$(echo ${php_ip} | awk -F. '{print $1"."$2"."$3".%"}')
        su -l webmaster -c "bash /tmp/init-site.sh ${install_dir} ${url} ${MYSQL_ROOT_PASSWORD} ${db_host} ${db_name} ${db_user} ${db_pwd} ${php_host} ${php_net}"

	echo "[BOKEH-NGINX] Set NGINX main conf files..."
	sed -i "s:INSTALLDIR:${install_dir}:g" /etc/nginx/nginx.conf
	sed -i "s:HOST:${local_host}:g" /etc/nginx/nginx.conf

        if [ ! -f /home/webmaster/${install_dir}/conf/nginx/${url}.conf ]
        then
                echo "[BOKEH-NGINX] Create NGINX conf files '${url}.conf'..."
                cp -p /tmp/site.conf /home/webmaster/${install_dir}/conf/nginx/${url}.conf
                sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/nginx/${url}.conf
		sed -i "s:BOKEH_URL:${url}:g" /home/webmaster/${install_dir}/conf/nginx/${url}.conf
        fi

	if [ ! -f /home/webmaster/${install_dir}/conf/nginx/bokeh-prod.inc ]
	then
		echo "[BOKEH-NGINX] Create NGINX conf files 'bokeh-prod.inc'..."
		cp -p /tmp/bokeh.inc /home/webmaster/${install_dir}/conf/nginx/bokeh-prod.inc
		sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/nginx/bokeh-prod.inc
		sed -i "s:PHPHOST:${php_host}:g" /home/webmaster/${install_dir}/conf/nginx/bokeh-prod.inc
	fi

        echo "[BOKEH-NGINX] Start nginx..."
        nginx -g "daemon off;"
}

main
