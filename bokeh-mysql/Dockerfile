FROM afi-mysql:latest
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV install_dir=www
ENV db_name=etalon
ENV MYSQL_ROOT_PASSWORD=root

COPY my.cnf /tmp/my.cnf
COPY bokeh.cnf /tmp/bokeh.cnf
RUN chown mysql:mysql /tmp/*.cnf
COPY bokeh.sql /tmp/bokeh.sql
COPY my.sh /tmp/my.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 3306
