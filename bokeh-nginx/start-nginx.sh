#!/bin/bash

function main {
        su -l webmaster -c "bash /tmp/init-site.sh ${install_dir} ${url} ${db_host} ${db_name} ${db_user} ${db_pwd}"

        if [ -z "$(ls -A /home/webmaster/${install_dir}/conf/nginx)" ]
        then
                echo "[BOKEH-NGINX] Install NGINX conf files..."
                cp -p /tmp/bokeh.inc /home/webmaster/${install_dir}/conf/nginx/
                cp -p /tmp/site.conf /home/webmaster/${install_dir}/conf/nginx/
                sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/nginx/bokeh.inc
                sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/nginx/site.conf
		sed -i "s:BOKEH_URL:${url}:g" /home/webmaster/${install_dir}/conf/nginx/site.conf
        fi

	sed -i "s:INSTALLDIR:${install_dir}:g" /etc/nginx/nginx.conf

        echo "[BOKEH-NGINX] Start nginx..."
        nginx -g "daemon off;"
}

main
