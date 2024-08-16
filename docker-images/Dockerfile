FROM debian:latest

LABEL maintainer="Edmundo Cespedes A. <a.k.a. eksys> ed.cespedesa@gmail.com"

ENV USER=bkpxdb \
    UID=10001

EXPOSE 3306
EXPOSE 5432

RUN apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends  -y \
    ca-certificates \
    sudo \
    bash-completion \
    curl \
    wget \
    git \
    vim

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

RUN groupadd -g "${UID}" "${USER}"

RUN useradd \
    -m \
    -s /bin/bash \
    -u "${UID}" \
    -g "${UID}" \
    "${USER}"
RUN passwd -d "${USER}"

RUN usermod -aG sudo "${USER}"

USER bkpxdb
WORKDIR /home/bkpxdb