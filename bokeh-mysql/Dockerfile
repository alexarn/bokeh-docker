FROM afi-mysql:latest
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV MYSQL_DATABASE=etalon
ENV MYSQL_USER=etalon
ENV MYSQL_PASSWORD=etalon
ENV MYSQL_ROOT_PASSWORD=root

ADD bokeh.cnf /etc/mysql/bokeh.cnf
ADD bokeh.sql /etc/mysql/bokeh.sql
ADD mysql.sh /etc/mysql/mysql.sh
RUN sed -i "11s:^:CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;\nUSE $MYSQL_DATABASE;\n:" /etc/mysql/bokeh.sql
RUN cp /etc/mysql/mysql.sh /docker-entrypoint-initdb.d
RUN cp /etc/mysql/bokeh.sql /docker-entrypoint-initdb.d

EXPOSE 3306
