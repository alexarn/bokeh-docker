FROM afi-nginx:latest
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV uid=500
ENV install_dir=www
ENV url=bokeh.local
ENV db_host=bokeh.local
ENV db_name=etalon
ENV db_user=etalon
ENV db_pwd=etalon

COPY nginx.conf /etc/nginx/nginx.conf
COPY bokeh.inc /tmp/bokeh.inc
COPY site.conf /tmp/site.conf
COPY bokeh-userfiles.tgz /tmp/bokeh-userfiles.tgz
COPY install-util.sh /tmp/install-util.sh
COPY init-site.sh /tmp/init-site.sh
COPY start-nginx.sh /start-nginx.sh

EXPOSE 80 443

ENTRYPOINT ["bash", "/start-nginx.sh"]
