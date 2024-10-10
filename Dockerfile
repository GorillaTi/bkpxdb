FROM debian:12.6

LABEL maintainer="Edmundo Céspedes A. <a.k.a. eksys> ed.cespedesa@gmail.com"

# Configurando zona horaria
ENV TZ=America/La_Paz
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Puertos habilitados
EXPOSE 3306 5432

# Actualizando paquetes
RUN apt-get update && apt-get upgrade -y 

# Instalación de paquetes necesarios
RUN apt-get install --no-install-recommends  -y \
    ca-certificates \
    bash-completion \
    inetutils-ping \
    curl \
    vim

# Instalación cron
RUN apt-get install -y cron

# Instalación clientes de base de datos
RUN apt-get install -y default-mysql-client \
    postgresql-client 

# Eliminando paquetes innecesarios
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Configurando Cron Jobs 
COPY src/crontab.example /etc/cron.d/bkpxdb-cron
RUN chown root:root /etc/cron.d/bkpxdb-cron && chmod 644 /etc/cron.d/bkpxdb-cron

# Copiando scrip de configuración de Cron Jobs
COPY src/cron-config.sh /usr/bin/cron-config
RUN chmod +x /usr/bin/cron-config

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