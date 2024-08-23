FROM debian:12.6

LABEL maintainer="Edmundo Céspedes A. <a.k.a. eksys> ed.cespedesa@gmail.com"

ENV TZ=America/La_Paz

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#EXPOSE 3306
#EXPOSE 5432

RUN apt-get update && apt-get upgrade -y 

RUN apt-get install --no-install-recommends  -y \
    ca-certificates \
    bash-completion \
    sudo \
    procps \
    curl \
    wget \
    vim

RUN apt-get install -y cron

RUN apt-get install -y mydumper \
    postgresql-client 

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Configurando script de prueba
COPY src/test.sh /bin/cron-test
RUN chmod 755 /bin/cron-test

# Configurando Cron Jobs de general
COPY src/crontab_root /etc/cron.d/bkpxdb-cron
RUN chmod 644 /etc/cron.d/bkpxdb-cron

# Configurando el directorio de trabajo de bkpxdb
RUN mkdir -p app/bkp_db app/scripts

# Configurando el directorio de trabajo scripts
COPY src/backup.sh app/scripts/backup.sh

# RUN chown -R bkpxdb:bkpxdb /home/"${USER}"/scripts
RUN chmod -R 755 app/scripts/*.sh

# # Configurando el directorio de trabajo de bkpxdb
RUN chmod -R 664 app/bkp_db

ENTRYPOINT  ["cron","-f"]