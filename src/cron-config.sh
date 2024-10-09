#!/usr/bin/env bash

# Copyright (c) 2024 Edmundo Cespedes A. <a.k.a. eksys>
# Author:  Edmundo Cespedes A.
# Licencia: MIT
# https://github.com/GorillaTi/bkpxdb/raw/main/LICENSE
# Name Script: run.sh
# Function:
# Configura  la hora de ejecucion del script  de copia de seguridad de las de bases de
# datos MYSQL MariaDn y PosrgreSQL
# Version: 2.0.0

# Exit if any command fails
set -eou pipefail

LOGS="/var/log/cron/cron.log"

{
    echo "Actualizando crontab"
    cp /app/crontab/crontab /etc/cron.d/bkpxdb-cron
    chown root:root /etc/cron.d/bkpxdb-cron
    chmod 644 /etc/cron.d/bkpxdb-cron

    echo "Starting crond... $(date)"
    #    service cron restart
} >>"$LOGS" 2>&1
