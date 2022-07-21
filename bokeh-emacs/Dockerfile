FROM archlinux:latest

ARG GROUP_ID
ARG USERNAME
ARG USER_ID

RUN pacman -Suy --noconfirm emacs-nox git the_silver_searcher wget openssh mariadb-clients

RUN pacman --noconfirm -Scc

RUN groupadd --system --gid ${GROUP_ID} ${USERNAME} \
    && useradd --system -m --home-dir /home/${USERNAME} --shell /bin/bash --gid ${GROUP_ID} --uid ${USER_ID} ${USERNAME}

COPY emacs.el /home/${USERNAME}/.emacs
RUN mkdir -p /home/${USERNAME}/.emacs.d/lisp
COPY mysql-query.el /home/${USERNAME}/.emacs.d/lisp/
COPY phafi-mode.el /home/${USERNAME}/.emacs.d/lisp/
COPY phpunit.el /home/${USERNAME}/.emacs.d/lisp/

RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.emacs*

COPY php /usr/local/bin/
COPY phpunit /usr/local/bin/
COPY dump_db /usr/local/bin/

RUN chmod +x /usr/local/bin/*

ENV LANG fr_FR.UTF-8
