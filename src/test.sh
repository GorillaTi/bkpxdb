#!/usr/bin/env bash

# Autor: Jose Mendoaza Vargas
#      : Edmundo Cespedes A.
# Licencia: MIT
# NOMBRE: bkp_db (copia_seg)
# Version: 2.0.0
# FUNSION:
# Captura de Usuario y fecha de ejecucion del script
echo "$(whoami) [$(date +%Y-%m-%d) - $(date +%H:%M:%S)]" >> /var/log/cron-test.log 2>&1