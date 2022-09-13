FROM afi-mariadb:latest
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV uid=500
ENV install_dir=www
ENV MYSQL_ROOT_PASSWORD=root

COPY my.cnf /tmp/my.cnf
COPY bokeh.cnf /tmp/bokeh.cnf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
COPY wait /wait
RUN chmod +x /wait

EXPOSE 3306
