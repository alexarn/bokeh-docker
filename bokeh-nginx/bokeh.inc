# Include directives for Bokeh portal

location ~ /\.(css|js)($|\?.*$) {
        add_header Cache-Control "max-age=604800, public";
        tcp_nodelay   off;
        try_files  $uri =404;
}

location ~ /\.(ico|pdf|flv|jpg|jpeg|png|gif|js|css|swf)$ {
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
        fastcgi_pass    unix:/run/php/php7.1-fpm.sock;
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
        fastcgi_pass    unix:/run/php/php7.1-fpm.sock;
}
