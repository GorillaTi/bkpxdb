FROM debian:12.6

LABEL maintainer="Edmundo Céspedes A. <a.k.a. eksys> ed.cespedesa@gmail.com"

# Configurando zona horaria
ENV TZ=America/La_Paz
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#EXPOSE 3306
#EXPOSE 5432

RUN apt-get update && apt-get upgrade -y 

RUN apt-get install --no-install-recommends  -y \
    ca-certificates \
    bash-completion \
    curl \
    vim

# Instalando cron
RUN apt-get install -y cron

# Instalando clientes de base de datos
RUN apt-get install -y mydumper \
    postgresql-client 

# Eliminando paquetes innecesarios
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Configurando Cron Jobs de general
COPY src/crontab_root /etc/cron.d/bkpxdb-cron
RUN chown root:root /etc/cron.d/bkpxdb-cron && chmod 644 /etc/cron.d/bkpxdb-cron

# Creando directorio de trabajo
RUN mkdir -p app/bkp_db app/scripts

# Copiando script de prueba
COPY src/test.sh app/scripts/cron-test.sh

# Copiando script de copia de seguridad
COPY src/backup.sh app/scripts/backup.sh

# Configurando permisos del directorio de trabajo scripts
RUN chmod -R 755 app/scripts/*.sh

# Configurando permisos del directorio de trabajo de bkpxdb
RUN chmod -R 664 app/bkp_db

# Directorio de trabajo
WORKDIR /app

# Iniciando servicio de cron
ENTRYPOINT  ["cron","-f"]