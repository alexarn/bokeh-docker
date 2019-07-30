FROM afi-mysql:latest
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV install_dir=www
ENV db_name=etalon
ENV MYSQL_ROOT_PASSWORD=root

COPY my.cnf /etc/mysql/my.cnf
COPY bokeh.cnf /tmp/bokeh.cnf
COPY bokeh.sql /tmp/bokeh.sql
COPY init-mysql.sh /tmp/init-mysql.sh
RUN bash /tmp/init-mysql.sh

EXPOSE 3306
