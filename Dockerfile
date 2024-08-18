FROM debian:12.6

LABEL maintainer="Edmundo Céspedes A. <a.k.a. eksys> ed.cespedesa@gmail.com"

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

RUN apt-get install -y mydumper \
    postgresql-client 

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

RUN mkdir -p /home/"${USER}"/scripts /home/${USER}/bkpxdb

COPY src/run.sh /home/"${USER}"/scripts/run.sh
COPY src/backup.sh /home/"${USER}"/scripts/backup.sh

RUN chown -R bkpxdb:bkpxdb /home/"${USER}"/scripts

USER bkpxdb
WORKDIR /home/bkpxdb