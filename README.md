# BkpXDB ![GitHub Repo stars](https://img.shields.io/github/stars/GorillaTi/bkpxdb) ![GitHub forks](https://img.shields.io/github/forks/GorillaTi/bkpxdb)

![GitHub Tag](https://img.shields.io/github/v/tag/GorillaTi/bkpxdb) 
![GitHub last commit](https://img.shields.io/github/last-commit/GorillaTi/bkpxdb) 
![Docker Pulls](https://img.shields.io/docker/pulls/ecespedes/bkpxdb) 
![GitHub License](https://img.shields.io/github/license/GorillaTi/bkpxdb) 

Copias de seguridad automatizada por medio de contenedor de los gestores de bases de datos MariaDB y PostgreSQL

## Instalación

### Instalación Desatendida

Instalando bkpxdb via curl

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/install.sh)"
```

Instalando bkpxdb via wget

```bash
sh -c "$(wget https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/install.sh -O -)"
```

### Instalación Manual  

Crear los directorios base necesarios

```bash
mkdir -p bkpxdb bkpxdb/src/list bkpxdb/logs/app bkpxdb/logs/cron
```

Cambiarse al directorio `bkpxdb`

```bash
cd bkpxdb
```

Descargando archivos necesarios

- db_list.csv

```bash
wget -nc -O "src/list/db_list.csv" https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/src/list/db_list.csv.example
```
<!-- 
- crontab

```bash
 wget -nc -O "src/crontab" https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/src/crontab.example
```

- .conf

```bash
wget -nc -O "src/.conf" https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/src/.conf.example
``` -->

- docker-compose.yml

```bash
wget -O "docker-compose.yml" https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/docker-compose.yml
```

Estructura de directorios y archivos

```shell
.
├── bkpxdb
│   ├── data
│   │   └── bkp_db
│   ├── docker-compose.yml
│   ├── logs
│   │   ├── app
│   │   └── cron
│   └── src
│       └── list
│           ├── db_list.csv
│           └── db.lst
└── install.sh
```

Para visualizar use el comando

```bash
tree -a
```

## Configuración Básicas

### Configuración archivo `db_list.csv`

```bash
vim src/list/db_list.csv
```

Ejemplo:

```shell
sysadmin;$Sistemas.123;172.16.20.20;3303;sysadmin;mysql
pgadmin;$Password.123;172.16.20.21;5433;sysadmin;pg
```

Es un archivo csv separado por comas con la siguiente estructura

#### Sintaxis archivo `db_list.csv`

```shell
sysadmin;$Sistemas.123;172.16.20.20;3303;sysadmin;mysql
    │        │               │       │     │       │
    │        │               │       │     │       │__	Tipo DB (mysql,mdb,pg)
    │        │               │       │     │__________	Usuario
    │        │               |       │________________	Puerto
    │        │               │________________________	IP Servidor
    │        │_______________________________________   Contraseña
    │________________________________________________   Usuario
```

### Configuración archivo `crontab`

```bash
docker exec -it bkpxdb vim crontab/crontab
```

Ejemplo:

```shell
# Copias de seguridad programadas
# Todos los días a las 23:30
30 23 * * * root /app/scripts/backup.sh
# Todos los días a las 13:30
30 13 * * * root /app/scripts/backup.sh
# Todos los días a las 19:30
30 19 * * * root /app/scripts/backup.sh

# Pruebas de funcionamiento de cron
* * * * * root date >> /var/log/cron/cron.log 2>&1
* * * * * root /app/scripts/cron-test.sh
*/10 * * * * root truncate -s 0 /var/log/cron/cron*.log
# New line charter required!
```

#### Sintaxis de `crontab`

```shell
* * * * * NOMBRE_USUARIO COMANDO/SCRIPT-A-EJECUTAR
│ │ │ │ │ │				│____  Comando a ejecutar
│ │ │ │ │ │___________________	Usuario que ejecutara el job
│ │ │ │ │_____________________	Día de la semana (0 – 6) (0 es domingo, o utilice nombres)
│ │ | │_______________________	Mes (1 – 12),* significa cada mes
│ │ │_________________________	Día del mes (1 – 31),* significa cada día
│ │___________________________	Hora (0 – 23),* significa cada hora
│_____________________________	Minuto (0 – 59),* significa cada minuto
```

### Cargando configuración

Situarse en el directorio `dkpxdb` y ejecutar el comando

```bash
docker exec -it bkpxdb cron-config
```

## Ejecución manual

```bash
docker exec -it bkpxdb /app/scripts/backup.sh
```

## Funcionalidades futuras

- Envió de los archivos `logs`  por medio de correo electrónico.
- Copia automatizada de los archivos de copia de seguridad a un dispositivo de almacenamiento de red.

## Revision de Logs

```bash
tail -f logs/app/error.log
```
Archivos de Logs:

- logs/app/error.log
- logs/app/info.log
- logs/app/warning.log
- logs/cron/cron-test.log
- logs/cron/cron.log

## Herramientas de formateo y comprobación de Cron

https://crontab-generator.org/

https://crontab.guru/

https://www.generateit.net/cron-job/
