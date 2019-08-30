FROM afi-nginx:latest
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV uid=500
ENV install_dir=www
ENV url=bokeh.local
ENV MYSQL_ROOT_PASSWORD=root
ENV db_host=bokeh-mysql
ENV db_name=etalon
ENV db_user=etalon
ENV db_pwd=etalon
ENV php_host=bokeh-php

COPY nginx.conf /etc/nginx/nginx.conf
COPY bokeh.inc /tmp/bokeh.inc
COPY bokeh.sql /tmp/bokeh.sql
COPY definer.sql /tmp/definer.sql
COPY site.conf /tmp/site.conf
COPY bokeh-userfiles.tgz /tmp/bokeh-userfiles.tgz
COPY init-site.sh /tmp/init-site.sh
COPY start-nginx.sh /start-nginx.sh
COPY wait /wait
RUN chmod +x /wait

EXPOSE 80 443

CMD /wait && bash /start-nginx.sh
