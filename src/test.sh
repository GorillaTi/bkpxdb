#!/usr/bin/env bash

# Copyright (c) 2024 Edmundo Cespedes A. <a.k.a. eksys>
# Author: Edmundo Cespedes A.
# Licencia: MIT
# https://github.com/GorillaTi/bkpxdb/raw/main/LICENSE
# Name Script: bkp_db (copia_seg)
# Function:
# Captura de Usuario y fecha de ejecucion del script
# Version: 2.0.0

echo "$(whoami) [$(date +%Y-%m-%d) - $(date +%H:%M:%S)]" >>/var/log/cron/cron-test.log 2>&1
