FROM afi-nginx:latest
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV install_dir=www
ENV url=bokeh.local
ENV db_name=etalon
ENV db_user=etalon
ENV db_pwd=etalon

COPY nginx.conf /etc/nginx/nginx.conf
COPY bokeh.inc /tmp/bokeh.inc
COPY site.conf /tmp/site.conf
COPY bokeh-userfiles.tgz /tmp/bokeh-userfiles.tgz
COPY init-deploy.sh /init-deploy.sh

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["bash", "/init-deploy.sh"]
CMD ["nginx", "-g", "daemon off;"]
