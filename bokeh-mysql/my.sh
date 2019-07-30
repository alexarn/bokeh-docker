#!/bin/bash

function main {
        if [ -z "$(ls -A /home/webmaster/${install_dir}/conf/mysql)" ]
        then
                echo "[BOKEH-MYSQL] Install MySQL conf files..."
		cp -p /tmp/bokeh.cnf /home/webmaster/${install_dir}/conf/mysql/
                sed -i "s:INSTALLDIR:${install_dir}:g" /home/webmaster/${install_dir}/conf/mysql/bokeh.cnf
        fi

	echo "[BOKEH-MYSQL] Prepare MySQL database..."
	cp -p /home/webmaster/${install_dir}/temp/${db_name}/1_create.sql /docker-entrypoint-initdb.d/1_create.sql
	cp -p /home/webmaster/${install_dir}/temp/${db_name}/2_insert.sql /docker-entrypoint-initdb.d/2_insert.sql
	cat /tmp/bokeh.sql >> /docker-entrypoint-initdb.d/2_insert.sql
	cp -p /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql /docker-entrypoint-initdb.d/3_update.sql
}

install_dir=$1
db_name=$2
main
