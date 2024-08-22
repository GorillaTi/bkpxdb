# BkpXDB

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
