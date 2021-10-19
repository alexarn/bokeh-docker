FROM mariadb:10.3
MAINTAINER AFI SA - Luc Deuffic <ldeuffic@afi-sa.fr>

ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils apt-transport-https
RUN apt-get install -y --no-install-recommends curl wget iputils-ping dnsutils net-tools lsb-release vim sudo mariadb-client rsync tzdata locales openssl libapr1-dev libssl-dev

RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

RUN sed -i '/fr_FR\.UTF/s/^# //g' /etc/locale.gen \
    && sed -i '/en_US\.UTF/s/^# //g' /etc/locale.gen \
    && locale-gen

RUN echo "mysql ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

EXPOSE 3306

CMD ["mysqld"]
