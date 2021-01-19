function main {
        if [ ! -d /home/webmaster/${install_dir} ]
        then
                echo "[BOKEH-NGINX] Prepare bokeh environment..."
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

	if [ ! -d /home/webmaster/${install_dir}/ftp/${url} ]
	then
		echo "[BOKEH-NGINX] Create files transfert subtree..."
		mkdir -p /home/webmaster/${install_dir}/ftp/${url}/cache
		mkdir -p /home/webmaster/${install_dir}/ftp/${url}/integration
		mkdir -p /home/webmaster/${install_dir}/ftp/${url}/log
		mkdir -p /home/webmaster/${install_dir}/ftp/${url}/transferts
		chmod 775 /home/webmaster/${install_dir}/ftp/${url}/*
	fi

        if [ ! -d /home/webmaster/${install_dir}/htdocs/${url} ]
        then
                echo "[BOKEH-NGINX] Create web site subtree..."
                mkdir -p /home/webmaster/${install_dir}/htdocs/${url}
                mkdir -p /home/webmaster/${install_dir}/htdocs/${url}/cosmogramme
                mkdir -p /home/webmaster/${install_dir}/htdocs/${url}/skins
                mkdir -p /home/webmaster/${install_dir}/htdocs/${url}/temp/epub
                mkdir -p /home/webmaster/${install_dir}/htdocs/${url}/temp/flash
                mkdir -p /home/webmaster/${install_dir}/htdocs/${url}/temp/vignettes_titre
                mkdir -p /home/webmaster/${install_dir}/htdocs/${url}/temp/autocomplete
                tar zxfp /tmp/bokeh-userfiles.tgz -C /home/webmaster/${install_dir}/htdocs/${url}/
                cp -p /home/webmaster/${install_dir}/php/bokeh/config.ini.default /home/webmaster/${install_dir}/htdocs/${url}/config.ini
                cp -p /home/webmaster/${install_dir}/php/bokeh/cosmogramme/config.ref.php /home/webmaster/${install_dir}/htdocs/${url}/cosmogramme/config.php
                source /home/webmaster/${install_dir}/php/install-util.sh
		createSymLinks /home/webmaster/${install_dir}/htdocs/${url} ../../php/bokeh
		updateConfig ${db_user} ${db_pwd} ${db_name} /home/webmaster/${install_dir}/htdocs/${url} ${db_host}

		echo "[BOKEH-NGINX] Clone initial skin..."
		mkdir -p /home/webmaster/${install_dir}/htdocs/${url}/skins/etalon
		git clone https://git.afi-sa.net/opac-skins/etalon.git /home/webmaster/${install_dir}/htdocs/${url}/skins/etalon

		echo "[BOKEH-NGINX] Set permissions..."
		chown -R webmaster:www-data /home/webmaster/${install_dir}/htdocs/${url}
		find /home/webmaster/${install_dir}/htdocs/${url} -type f -exec chmod 664 {} \;
		find /home/webmaster/${install_dir}/htdocs/${url} -type d -exec chmod 775 {} \;

		echo "[BOKEH-NGINX] Create MySQL setup scripts..."
		mkdir -p /home/webmaster/${install_dir}/temp/${db_name}
		echo "drop database if exists "${db_name}";" > /home/webmaster/${install_dir}/temp/${db_name}/1_create.sql
		echo "create database "${db_name}" CHARACTER SET utf8 COLLATE utf8_general_ci;" >> /home/webmaster/${install_dir}/temp/${db_name}/1_create.sql
		echo "grant all on ${db_user}.* to '${db_user}'@'${php_host}' identified by '${db_pwd}';" >> /home/webmaster/${install_dir}/temp/${db_name}/1_create.sql
		echo "flush privileges;" >> /home/webmaster/${install_dir}/temp/${db_name}/1_create.sql

		echo "use "${db_name}";" > /home/webmaster/${install_dir}/temp/${db_name}/2_insert.sql
		cat /tmp/bokeh.sql >> /home/webmaster/${install_dir}/temp/${db_name}/2_insert.sql
		sed -i "s:USERNAME:${db_user}:g" /tmp/definer.sql
		sed -i "s:HOST:${php_host}:g" /tmp/definer.sql
		cat /tmp/definer.sql >> /home/webmaster/${install_dir}/temp/${db_name}/2_insert.sql

		echo "use "${db_name}";" > /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE bib_admin_profil SET TITRE_SITE='"${url}"' WHERE bib_admin_profil.ID_PROFIL=1 ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE bib_admin_users SET LOGIN='"${db_user}"' WHERE bib_admin_users.ID_USER=20101 ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE bib_admin_users SET PASSWORD='"${db_pwd}"' WHERE bib_admin_users.ID_USER=20101 ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE bib_c_site SET LIBELLE='"${db_user}"' WHERE bib_c_site.ID_SITE=1 ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE bib_c_site SET VILLE='http://"${url}"' WHERE bib_c_site.ID_SITE=1 ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE int_bib SET nom_court='"${db_user}"' WHERE int_bib.id_bib=1 ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE variables SET valeur='"${db_pwd}"' WHERE variables.clef='catalog_pwd' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE variables SET valeur='"${db_user}"' WHERE variables.clef='admin_login' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE variables SET valeur='"${db_user}"' WHERE variables.clef='admin_pwd' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE variables SET valeur='../../ftp/"${url}"/log/' WHERE variables.clef='log_path' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE variables SET valeur='../../ftp/"${url}"/transferts/' WHERE variables.clef='ftp_path' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE variables SET valeur='../../ftp/"${url}"/integration/' WHERE variables.clef='integration_path' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE variables SET valeur='../../ftp/"${url}"/cache/' WHERE variables.clef='cache_path' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE variables SET valeur='"${db_user}"' WHERE variables.clef='mail_retard_sujet' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE variables SET valeur='http://"${url}"' WHERE variables.clef='url_site' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE bib_admin_var SET valeur='http://"${url}"/cosmogramme' WHERE bib_admin_var.clef='URL_COSMOGRAMME' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE bib_admin_var SET valeur='"${url}"' WHERE bib_admin_var.clef = 'NOM_DOMAINE' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql
		echo "UPDATE bib_admin_var SET valeur='' where clef='BUID' ;" >> /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql

		mysql -h ${db_host} -u root -p${mysql_root_passwd} -A mysql < /home/webmaster/${install_dir}/temp/${db_name}/1_create.sql
		mysql -h ${db_host} -u root -p${mysql_root_passwd} -A mysql < /home/webmaster/${install_dir}/temp/${db_name}/2_insert.sql
		mysql -h ${db_host} -u root -p${mysql_root_passwd} -A mysql < /home/webmaster/${install_dir}/temp/${db_name}/3_update.sql

		echo "[BOKEH-NGINX] Set Bokeh DB access rights..."
		echo "grant all on "${db_user}".* to '"${db_user}"'@'"${php_host}"' identified by '"${db_pwd}"';" > /home/webmaster/${install_dir}/temp/${db_name}/4_grant.sql
		echo "grant all on "${db_user}".* to '"${db_user}"'@'"${php_net}"' identified by '"${db_pwd}"';" >> /home/webmaster/${install_dir}/temp/${db_name}/4_grant.sql
		echo "flush privileges;" >> /home/webmaster/${install_dir}/temp/${db_name}/4_grant.sql

		 mysql -h ${db_host} -u root -p${mysql_root_passwd} -A mysql < /home/webmaster/${install_dir}/temp/${db_name}/4_grant.sql

		successMessage
		printErrors
	fi
}

install_dir=$1
url=$2
mysql_root_passwd=$3
db_host=$4
db_name=$5
db_user=$6
db_pwd=$7
php_host=$8
php_net=$9

main
