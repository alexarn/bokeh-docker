# Include directives for Bokeh portal

location ~ ^.*\.(css|js)($|\?.*$) {
        add_header Cache-Control "max-age=604800, public";
        tcp_nodelay   off;
        try_files  $uri =404;
}


location ~ ^\/(userfiles|public|tmp|temp|skins|library\/templates|library\/digital_resources)\/.*\.(ico|txt|gif|jpg|jpeg|png|xml|swf|mov|pdf|doc|docx|woff|woff2|eot|svg|ttf|xls|xlsx|xlsm|wsdl|mp3|m4v|ogg|ogv|epub|htm|html|xhtml|asmx|zip|sql|bro|flv|mp4|webm|webp|tgz|json|geojson|xsl|ods|odp|odt|ots|ott|odm|odg|otg|otp)$ {
        add_header Cache-Control "max-age=604800, public";
        tcp_nodelay   off;
        try_files  $uri =404;
}

location = /favicon.ico {
        log_not_found off;
        access_log off;
}

location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
}

# Deny access to sensitive files.
location ~ (\.inc\.php|\.tpl|\.sql|\.tpl\.php|\.db)$ {
        return 403;
}
location ~ /(\.|\.htaccess|config\.(ini|php)) {
        return 403;
}

#Serve PHP
location ~ /cosmogramme/cosmozend {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include fastcgi_params;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME    $document_root/cosmogramme/cosmozend/index.php;
        fastcgi_param  SCRIPT_NAME        /cosmogramme/cosmozend/index.php;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 256 4k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
        fastcgi_intercept_errors on;
	fastcgi_pass PHPHOST:9000;
}

location ~ (\.php$|/(cosmogramme|exploit/(test\.php|fpm-ping|fpm-status))) {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include fastcgi_params;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
        fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 256 4k;
        fastcgi_busy_buffers_size 256k;
        fastcgi_temp_file_write_size 256k;
        fastcgi_intercept_errors on;
	fastcgi_pass PHPHOST:9000;
}

location ^~ /xhprof_html/ {
	root /home/webmaster/INSTALLDIR/php/bokeh/xhprof;
	include fastcgi_params;
	fastcgi_index  index.php;
	fastcgi_param SCRIPT_FILENAME	$document_root$fastcgi_script_name;
	fastcgi_pass PHPHOST:9000;

	location ~ ^.*\.(css|js|gif)$ {}
}
