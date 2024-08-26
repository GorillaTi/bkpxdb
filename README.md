# BkpXDB

![GitHub Tag](https://img.shields.io/github/v/tag/GorillaTi/bkpxdb)
![GitHub last commit](https://img.shields.io/github/last-commit/GorillaTi/bkpxdb)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/GorillaTi/bkpxdb/main)
![Docker Pulls](https://img.shields.io/docker/pulls/ecespedes/bkpxdb)
![GitHub License](https://img.shields.io/github/license/GorillaTi/bkpxdb)
![GitHub Repo stars](https://img.shields.io/github/stars/GorillaTi/bkpxdb)
![GitHub forks](https://img.shields.io/github/forks/GorillaTi/bkpxdb)

Copias de seguridad de los gestores de bases de datos MariaDB y PostgreSQL

## Sintaxis de Crontab

```
* * * * * NOMBRE_USUARIO COMANDO/SCRIPT-A-EJECUTAR
│ │ │ │ │ │				│____  Comando a ejecutar
│ │ │ │ │ │___________________	Usuario que ejecutara el job
│ │ │ │ │_____________________	Día de la semana (0 – 6) (0 es domingo, o utilice nombres)
│ │ | │_______________________	Mes (1 – 12),* significa cada mes
│ │ │_________________________	Día del mes (1 – 31),* significa cada día
│ │___________________________	Hora (0 – 23),* significa cada hora
│_____________________________	Minuto (0 – 59),* significa cada minuto
```

## Directorios de Trabajo

Directorio de configuracion:

```shell
/etc/crontab
```

Directorio para todos

```shell
/etc/cron.d/
```

Directorio por usuario

```shell
/var/spool/cron/
```

## Herramientas de formateo y comprobación de Cron

https://crontab-generator.org/

https://crontab.guru/

https://www.generateit.net/cron-job/
