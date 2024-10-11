#!/usr/bin/env bash

# Copyright (c) 2024 Edmundo Cespedes A. <a.k.a. eksys>
# Author: Edmundo Cespedes A.
# Licencia: MIT
# https://github.com/GorillaTi/bkpxdb/raw/main/LICENSE
# Name Script: install.sh
# Function:
# Instalación de la herramienta de copia de seguridad de bases de datos
# Version: 1.0.0

# Variables Globales
tmp_logs="/tmp/logs.log"

# Exit if any command fails
set -eou pipefail

f_create_directories() {
    # Variables locales
    local status=0
    local ress
    local directorie="$1"

    # Creando un directorio
    while [ "$status" -le 0 ]; do
        # Verificando la existencia de los direcorios
        if [ ! -d "$directorie" ]; then
            echo "[WARNING] Directorio $directorie no encontrado" >>"$tmp_logs" 2>&1
            # Creando el directorio
            mkdir -p "$directorie"
            # Validadndo la cracion del directorio
            ress=${?}
            if [[ $ress -eq 0 ]]; then
                echo "[WARNING] Directorio $directorie creado con exito" >>"$tmp_logs" 2>&1
                status=0
            else
                echo "[ERROR] Directorio $directorie  no creado " >>"$tmp_logs" 2>&1
                exit 1
            fi
        else
            echo "[INFO] Directorio $directorie encontrado" >>"$tmp_logs" 2>&1
            status=1
        fi
    done
}
f_install() {
    # Variables locales
    local dir_root="bkpxdb"
    local dir_src="src"
    local dir_data="data"
    local dir_config="config"
    local dir_log="logs"
    local repo_url="https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/$1"

    # Generando estructura de directorios necesarias
    # Directorio raiz
    f_create_directories "$dir_root"

    # Creando directorio de fuente
    f_create_directories "$dir_root/$dir_src"
    f_create_directories "$dir_root/$dir_src/list"

    #Creando directorio de logs
    f_create_directories "$dir_root/$dir_log"
    f_create_directories "$dir_root/$dir_log/app"
    f_create_directories "$dir_root/$dir_log/cron"

    #Creando directorio de bkp
    f_create_directories "$dir_root/$dir_data"
    f_create_directories "$dir_root/$dir_data/$dir_config"

    # Descargando archiivos necesarios
    # db.lst
    if [[ -f "$dir_root/$dir_src/list/db.lst" ]]; then
        echo "[INFO] El archivo $dir_root/$dir_src/list/db.lst ya existe" >>"$tmp_logs" 2>&1
    else
        {
            wget -nc -O "$dir_root/$dir_src/list/db.lst" "$repo_url/src/list/db.lst.example"
            echo "[WARNING] El archivo $dir_root/$dir_src/list/db.lst ha sido descargado"
        } >>"$tmp_logs" 2>&1
    fi
    # db_list.csv
    if [[ -f "$dir_root/$dir_src/list/db_list.csv" ]]; then
        echo "[INFO] El archivo $dir_root/$dir_src/list/db_list.csv ya existe" >>"$tmp_logs" 2>&1
    else
        {
            wget -nc -O "$dir_root/$dir_src/list/db_list.csv" "$repo_url/src/list/db_list.csv.example"
            echo "[WARNING] El archivo $dir_root/$dir_src/list/db_list.csv ha sido descargado"
        } >>"$tmp_logs" 2>&1
    fi
    #crontab
    if [[ -f "$dir_root/$dir_src/crontab" ]]; then
        echo "[INFO] El archivo $dir_root/$dir_src/crontab ya existe" >>"$tmp_logs" 2>&1
    else
        {
            wget -nc -O "$dir_root/$dir_src/crontab" "$repo_url/src/crontab.example"
            echo "[WARNING] El archivo $dir_root/$dir_src/crontab ha sido descargado"
        } >>"$tmp_logs" 2>&1
    fi
    #.conf
    if [[ -f "$dir_root/$dir_src/.conf" ]]; then
        echo "[INFO] El archivo $dir_root/$dir_src/.conf ya existe" >>"$tmp_logs" 2>&1
    else
        {
            wget -nc -O "$dir_root/$dir_src/.conf" $repo_url/src/.conf.example
            echo "[WARNING] El archivo $dir_root/$dir_src/.conf ha sido descargado"
        } >>"$tmp_logs" 2>&1
    fi
    # crontab
    if [[ -f "$dir_root/$dir_data/$dir_config/bkpxdb-cron" ]]; then
        echo "[INFO] El archivo $dir_root/$dir_data/$dir_config/bkpxdb-cron ya existe" >>"$tmp_logs" 2>&1
    else
        {
            wget -nc -O "$dir_root/$dir_data/$dir_config/bkpxdb-cron" "$repo_url/src/crontab.example"
            echo "[WARNING] El archivo $dir_root/$dir_data/$dir_config/bkpxdb-cron ha sido descargado"
        } >>"$tmp_logs" 2>&1
    fi

    # docker-compose.yml
    if [[ -f "$dir_root/docker-compose.yml" ]]; then
        echo "[INFO] El archivo $dir_root/docker-compose.yml ya existe" >>"$tmp_logs" 2>&1
    else
        {
            wget -O "$dir_root/docker-compose.yml" "$repo_url/docker-compose.yml"
            echo "[WARNING] El archivo $dir_root/docker-compose.yml ha sido descargado"
        } >>"$tmp_logs" 2>&1
    fi

    tree -a "bkpxdb" >>"$tmp_logs" 2>&1
    echo "Cambiando al directorio $dir_root" >>"$tmp_logs" 2>&1

    cd $dir_root >>"$tmp_logs" 2>&1
    echo "Inicial el contenedor ejecutar" >>"$tmp_logs" 2>&1

    docker compose up -d >>"$tmp_logs" 2>&1

    echo "Contenedor inicializado con el  nombre bkpxdb" >>"$tmp_logs" 2>&1
}
# Ejecutando la instalación
truncate -s 0 "$tmp_logs"
echo "################## INICIANDO LA INSTALACIO $(date +"%Y-%m-%d_%H:%M:%S")##################" >>"$tmp_logs" 2>&1
f_install "12-solucion-de-problemas"
docker exec -it bkpxdb chown root:root /etc/cron.d/bkpxdb-cron >>"$tmp_logs" 2>&1
echo "################## FIN DE LA INSTALACION $(date +"%Y-%m-%d_%H:%M:%S")##################" >>"$tmp_logs" 2>&1
cat "$tmp_logs" >"install_$(date +"%Y-%m-%d_%H:%M:%S").log"
