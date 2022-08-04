FROM archlinux:latest

ARG GROUP_ID
ARG USERNAME
ARG USER_ID
ARG DOCKER_GROUP_ID
ARG MARIADB_ROOT_PASSWORD

RUN groupadd --system --gid ${DOCKER_GROUP_ID} docker

RUN pacman -Suy --noconfirm emacs-nox git the_silver_searcher wget openssh mariadb-clients global docker yaz

RUN pacman --noconfirm -Scc

RUN groupadd --gid ${GROUP_ID} ${USERNAME} \
    && useradd -m --home-dir /home/${USERNAME} -G docker --shell /bin/bash --gid ${GROUP_ID} --uid ${USER_ID} ${USERNAME}

COPY emacs.el /home/${USERNAME}/.emacs
ADD lisp /home/${USERNAME}/.emacs.d/lisp
RUN sed -i "s:MARIADB_ROOT_PASSWORD:${MARIADB_ROOT_PASSWORD}:" /home/${USERNAME}/.emacs
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.emacs*

COPY php /usr/local/bin/
COPY pman /usr/local/bin/
COPY phpunit /usr/local/bin/
COPY dump_db /usr/local/bin/
RUN sed -i "s:MARIADB_ROOT_PASSWORD:${MARIADB_ROOT_PASSWORD}:" /usr/local/bin/dump_db
COPY show_db /usr/local/bin/
RUN sed -i "s:MARIADB_ROOT_PASSWORD:${MARIADB_ROOT_PASSWORD}:" /usr/local/bin/show_db
copy autofocus /usr/local/bin/

RUN chmod +x /usr/local/bin/*

COPY emacs-env.sh /etc/profile.d/

ENV LANG fr_FR.UTF-8
