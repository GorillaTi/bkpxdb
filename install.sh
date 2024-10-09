#!/usr/bin/env bash

# Copyright (c) 2024 Edmundo Cespedes A. <a.k.a. eksys>
# Author: Edmundo Cespedes A.
# Licencia: MIT
# https://github.com/GorillaTi/bkpxdb/raw/main/LICENSE
# Name Script: install.sh
# Function:
# Instalación de la herramienta de copia de seguridad de bases de datos
# Version: 1.0.0

# Exit if any command fails
# set -eou pipefail

f_create_directories() {
    # Variables locales
    local status=0
    local ress
    local directorie="$1"

    # Creando un directorio
    while [ "$status" -le 0 ]; do
        # Verificando la existencia de los direcorios
        if [ ! -d "$directorie" ]; then
            echo "[WARNING] Directorio $directorie no encontrado"
            # Creando el directorio
            mkdir -p "$directorie"
            # Validadndo la cracion del directorio
            ress=${?}
            if [[ $ress -eq 0 ]]; then
                echo "[WARNING] Directorio $directorie creado con exito"
                status=0
            else
                echo "[ERROR] Directorio $directorie  no creado "
                exit 1
            fi
        else
            echo "[INFO] Directorio $directorie encontrado"
            status=1
        fi
    done
}
f_install() {
    # Variables locales
    local dir_root="bkpxdb"
    local dir_src="src"
    local dir_data="data"
    local dir_log="logs"

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

    # Descargando archiivos necesarios
    # db.lst
    if [[ -f "$dir_root/$dir_src/list/db.lst" ]]; then
        echo "[INFO] El archivo $dir_root/$dir_src/list/db.lst ya existe"
    else
        wget -nc -O "$dir_root/$dir_src/list/db.lst" https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/src/list/db.lst.example
        echo "[WARNING] El archivo $dir_root/$dir_src/list/db.lst ha sido descargado"
    fi
    # db_list.csv
    if [[ -f "$dir_root/$dir_src/list/db_list.csv" ]]; then
        echo "[INFO] El archivo $dir_root/$dir_src/list/db_list.csv ya existe"
    else
        wget -nc -O "$dir_root/$dir_src/list/db_list.csv" https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/src/list/db_list.csv.example
        echo "[WARNING] El archivo $dir_root/$dir_src/list/db_list.csv ha sido descargado"
    fi
    # TODO: modificacion de forma de configuracion de crontab
    # crontab
    # if [[ -f "$dir_root/$dir_src/crontab" ]]; then
    #     echo "[INFO] El archivo $dir_root/$dir_src/crontab ya existe"
    # else
    #     wget -nc -O "$dir_root/$dir_src/crontab" https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/src/crontab.example
    #     echo "[WARNING] El archivo $dir_root/$dir_src/crontab ha sido descargado"
    # fi
    # FIXME: solucionar problemas de funcionamiento
    # .conf
    # if [[ -f "$dir_root/$dir_src/.conf" ]]; then
    #     echo "[INFO] El archivo $dir_root/$dir_src/.conf ya existe"
    # else
    #     wget -nc -O "$dir_root/$dir_src/.conf" https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/src/.conf.example
    #     echo "[WARNING] El archivo $dir_root/$dir_src/.conf ha sido descargado"
    # fi
    # docker-compose.yml
    if [[ -f "$dir_root/docker-compose.yml" ]]; then
        echo "[INFO] El archivo $dir_root/docker-compose.yml ya existe"
    else
        wget -O "$dir_root/docker-compose.yml" https://raw.githubusercontent.com/GorillaTi/bkpxdb/refs/heads/main/docker-compose.yml
        echo "[WARNING] El archivo $dir_root/docker-compose.yml ha sido descargado"
    fi
    tree -a "bkpxdb"
    echo "Cambiando al directorio $dir_root"
    # echo "cd $dir_root"
    cd $dir_root
    echo "Inicial el contenedor ejecutar"
    # echo "docker compose up -d "
    docker compose up -d
}
f_install
