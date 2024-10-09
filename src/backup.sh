#!/usr/bin/env bash

# Copyright (c) 2024 Edmundo Cespedes A. <a.k.a. eksys>
# Author: Edmundo Cespedes A.
# Licencia: MIT
# https://github.com/GorillaTi/bkpxdb/raw/main/LICENSE
# Name Script: backup.sh
# Function:
# Backup of MYSQL MariaDn and PosrgreSQL databases
# Version: 3.0.0

# Exit if any command fails
set -eou pipefail

# ===============================================================================
# VARIABLES GLOBALES
# ===============================================================================

# Directorio Actual
DIR_ACTUAL=$(pwd)

# Archivos de Logs del Script
ERROR_LOG="/var/log/app/error.log"  # Logs de Error del script
WARN_LOG="/var/log/app/warning.log" # Logs de Advertencia del script
INF_LOG="/var/log/app/info.log"     # Logs de Informacion del script

# Archivos de Logs del  Backup
ERROR_BKP_LOG="/tmp/error_bkp.log"  # Logs de Error del Back-Up
WARN_BKP_LOG="/tmp/warning_bkp.log" # Logs de Advertencia del Back-Up
INF_BKP_LOG="/tmp/info_bkp.log"     # Logs de Informacion del Back-Up
TEMP_BKP_LOG="/tmp/tmp_bkp.log"     # Logs Temporal  del Back-Up

# -----------------------------------------------------------------------------
# f_gestion_logs(tipo, mensaje)
#
# Genera un mensaje de log seg n el tipo de log que se desee.
#
# Parametros:
#   - tipo: Tipo de log a crear (i, w, e, ibkp, wbkp, ekbkp)
#   - mensaje: Mensaje a incluir en el log
#
# Retorno:
#   - Ninguno
f_gestion_logs() {
	# Variables locales
	local msg_log="$2"
	local t_log
	local arch_log
	# Generando mensajes de logs
	case "$1" in
	"i")
		t_log="INFO"
		arch_log=$INF_LOG
		;;
	"w")
		t_log="WARNING"
		arch_log=$WARN_LOG
		;;
	"e")
		t_log="ERROR"
		arch_log=$ERROR_LOG
		;;
	"ibkp")
		t_log="INFO"
		arch_log=$INF_BKP_LOG
		;;
	"wbkp")
		t_log="WARNING"
		arch_log=$WARN_BKP_LOG
		;;
	"ebkp")
		t_log="ERROR"
		arch_log=$ERROR_BKP_LOG
		;;
	"tbkp")
		t_log="$3"
		arch_log=$TEMP_BKP_LOG
		;;
	*)
		t_log="ERROR"
		arch_log=$ERROR_LOG
		msg_log="Tipo de log no valido"
		;;
	esac
	# Mensaje de Logs
	echo "[$t_log $(date +%Y-%m-%d:%H:%M)] $msg_log." >>"$arch_log"
}

#  BUG: Cargando las variables de entorno desde el archivo .conf
# Cargar las variables de entorno desde el archivo .conf
# if [[ -f "$DIR_ACTUAL/scripts/.conf" ]]; then
# . "$DIR_ACTUAL/scripts/.conf"
# f_gestion_logs "i" "Variables de Entorno cargadas desde .conf"
# else
# f_gestion_logs "e" "El archivo .conf no existe"
# fi

# TODO: Validar que las variables de entorno esten cargadas
# Configuración del equipo remoto
# REMOTE_USER=$R_USER
# REMOTE_HOST=$R_HOST
# REMOTE_DIR=$R_DIR
# REMOTE_PASS=$R_PASS

# Dia , mes, hora y año actual
DIA_ACTUAL=$(date +%d)
MES_ACTUAL=$(date +%m)
ANIO_ACTUAL=$(date +%Y)
HORA_ACTUAL=$(date +%H)

# Tipo de origen de archovo de datos de DB
T_ARCH="${TIPO_LISTA:-csv}"

# Directorio Scripts
DIR_SCRIPTS="$DIR_ACTUAL/scripts"

# ubicacion archivos de datos de DB
A_LIST="$DIR_SCRIPTS/list/db.lst"
A_CSV="$DIR_SCRIPTS/list/db_list.csv"

# Directorio BKP
DIR_BKP="${D_BKP:-bkp_db}"

# Directorios de trabajo
unset DIR_O
unset DIR_A
unset DIR_M
unset DIR_D
unset DIR_H

# ===============================================================================
# FUNCIONES
# ===============================================================================
# FUNCION DE LECTURA DE LOGS
# ------------------------------------------------------------------------------------
# f_read_logs(activate)
# Muestra los archivos de logs (error, warning, y info respectivamente)
# Si el parametro activate es "a" entonces muestra los logs
# Si el parametro activate es diferente a "a" no muestra los logs
#
# Parameters:
#   activate - string, si es "a" muestra los logs
#
# Returns:
#   None
#
# Examples:
#   f_read_logs "a"
# ------------------------------------------------------------------------------------
f_read_logs() {
	# Variables locales
	local activate=$1

	# Mostrando los archivos de logs
	case $activate in
	"script")
		if [[ -f $ERROR_LOG ]]; then
			# echo "################## ERROR SCRIPT LOGS ##################"
			cat "$ERROR_LOG"
		fi
		if [[ -f $WARN_LOG ]]; then
			# echo "################## WARNING SCRIPT LOGS ##################"
			cat "$WARN_LOG"
		fi
		if [[ -f $INF_LOG ]]; then
			# echo "################## INFO SCRIPT LOGS ##################"
			cat "$INF_LOG"
		fi
		;;
	"bkp")
		if [[ -f $ERROR_BKP_LOG ]]; then
			# echo "################## ERROR BKP LOGS ##################"
			cat "$ERROR_BKP_LOG"
		fi
		if [[ -f $WARN_BKP_LOG ]]; then
			# echo "################## WARNING BKP LOGS ##################"
			cat "$WARN_BKP_LOG"
		fi
		if [[ -f $INF_BKP_LOG ]]; then
			# echo "################## INFO BKP LOGS ##################"
			cat "$INF_BKP_LOG"
		fi
		;;
	"all")
		# Mostrando los archivos de logs
		if [[ -f $ERROR_LOG ]]; then
			echo "################## ERROR SCRIPT LOGS ##################"
			cat "$ERROR_LOG"
		fi
		if [[ -f $WARN_LOG ]]; then
			echo "################## WARNING SCRIPT LOGS ##################"
			cat "$WARN_LOG"
		fi
		if [[ -f $INF_LOG ]]; then
			echo "################## INFO SCRIPT LOGS ##################"
			cat "$INF_LOG"
		fi
		if [[ -f $ERROR_BKP_LOG ]]; then
			echo "################## ERROR BKP LOGS ##################"
			cat "$ERROR_BKP_LOG"
		fi
		if [[ -f $WARN_BKP_LOG ]]; then
			echo "################## WARNING BKP LOGS ##################"
			cat "$WARN_BKP_LOG"
		fi
		if [[ -f $INF_BKP_LOG ]]; then
			echo "################## INFO BKP LOGS ##################"
			cat "$INF_BKP_LOG"
		fi
		;;
	"tmp")
		if [[ -f $TEMP_BKP_LOG ]]; then
			cat "$TEMP_BKP_LOG"
		fi
		;;
	*)
		# No se activo la captura de Logs
		echo "No se activo la visualizacion de los archivos de Logs"
		;;
	esac
}
# FIXME: ver si se utiliza esta funcion
f_write_logs() {
	if [[ -f $LOG_FILE ]]; then
		{
			echo "################## INITIAL LOGS  $(date +%Y-%m-%d:%H:%M)##################"
			f_read_logs "a"
			echo "################## END LOGS  $(date +%Y-%m-%d:%H:%M)##################"
		} >>"$LOG_FILE"
	else
		f_gestion_logs "e" "No se encontro el archivo de logs_file.log"
	fi
}

# SELECCIONA LA HORA DEL DIA
# ------------------------------------------------------------------------------------
# f_time_day()
# Selecciona la hora del dia y determina si es
# 13:00 - Medio dia
# 19:00 - Media tarde
# 23:00 - Media noche
# Otro valor - Temporal
# ------------------------------------------------------------------------------------
f_time_day() {
	# Variables locales
	local hora_dia

	# Determinando la hora
	case $HORA_ACTUAL in
	# 13:00 - Medio dia
	"13")
		hora_dia="medio-dia"
		;;
	# 19:00 - Media tarde
	"19")
		hora_dia="media-tarde"
		;;
	# 23:00 - Media noche
	"23")
		hora_dia="media-noche"
		;;
	*)
		# Otro valor - Temporal
		hora_dia="temporal"
		;;
	esac
	echo "$hora_dia"
}

# CREADOR DE DIRECTORIOS
# ------------------------------------------------------------------------------------
# f_add_dir()
#
# Crea un nuevo directorio dentro de otro directorio existente.
#
# Parametros:
#   - dir_orig: El directorio existente donde se creara el nuevo directorio.
#   - dir_new: El nombre del nuevo directorio a crear.
#
# Retorno:
#   - Si se crea el nuevo directorio, retorna la ruta completa del directorio creado.
#   - Si no se crea el nuevo directorio, retorna un mensaje de error.
# ------------------------------------------------------------------------------------
f_add_dir() {
	# Variables locales
	local dir_orig="$1" # directorio donde se creara el nuevo directorio
	local dir_new="$2"  # nombre del nuevo directorio

	# Verificando si el directorio origen existe
	if [[ -d $dir_orig ]]; then
		# Cargando la estructura del nuevo directorio
		local dir_add="$dir_orig/$dir_new"
		# Creando el directorio
		if [[ ! -d $dir_add ]]; then
			# Creando el directorio
			mkdir -p "$dir_add"
			# Cargando la variable de estado
			local stts="$?"
			# Comprobando el resultado de la creacion del directorio
			if [[ $stts -eq 0 ]]; then
				# Si se crea el nuevo directorio, se registra el mensaje de log
				f_gestion_logs "wbkp" "Directorio $dir_new creado en $dir_orig"
				echo "$dir_add" # Retornando la ruta completa del directorio creado
			else
				# Si no se crea el nuevo directorio, se registra el mensaje de log con el error
				f_gestion_logs "ebkp" "No se pudo crear el $dir_new."
				exit 1 # Termina la ejecucion del script
			fi
		else
			# Si el directorio ya existe, se registra el mensaje de log
			f_gestion_logs "ibkp" "Directorio $dir_new existente en $dir_orig"
			echo "$dir_add" # Retornando la ruta completa del directorio existente
		fi
	else
		# Si el directorio origen no existe, se registra el mensaje de error
		f_gestion_logs "e" "El directorio $dir_orig no existe"
		exit 1 # Termina la ejecucion del script
	fi
}

# CREADOR DE ARCHIVOS
# ------------------------------------------------------------------------------
# f_add_arch()
#
# Crea un nuevo archivo en el directorio proporcionado.
#
# Parametros:
#   - DIR_DEST: El directorio donde se creara el nuevo archivo.
#   - arch_new: El nombre del nuevo archivo a crear.
#
# Retorno:
#   - Si se crea el nuevo archivo, retorna la ruta completa del archivo creado.
#   - Si no se crea el nuevo archivo, retorna un mensaje de error.
# ------------------------------------------------------------------------------
f_add_arch() {
	# Variables locales
	local DIR_DEST="$1"
	local arch_new="$2"

	# Verificando si el directorio destino existe
	if [[ -d $DIR_DEST ]]; then
		# Cargando la estructura del nuevo archivo
		local arch_add="$DIR_DEST/$arch_new"
		# Creando el archivo
		if [[ ! -f $arch_add ]]; then
			# Creando el archivo
			touch "$arch_add"
			# Cargando la variable de estado
			local stts="$?"
			# Comprobando el resultado de la creacion archivo
			if [[ $stts -eq 0 ]]; then
				echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Archivo $arch_new creado en $DIR_DEST" >>"$WARN_LOG"
				echo "$arch_add"
			else
				echo "[ERROR $(date +%Y-%m-%d:%H:%M)] No se pudo crear $arch_new." >>"$ERROR_LOG"
				exit 1
			fi
		else
			echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Archivo $arch_new existente en $DIR_DEST" >>"$WARN_LOG"
			echo "$arch_add"
		fi
	else
		echo "El directorio $DIR_DEST no existe"
		exit 1
	fi
}
# TODO: Comprobar el funcionamiento y correccion del direccionamiento de logs
# BACKUP DESDE DB.LIST
# ------------------------------------------------------------------------------
# f_backup_list()
#
# Crea las copias de seguridad de las bases de datos que se encuentran
# en el archivo db.lst
#
# Parametros:
#   - Ninguno
#
# Retorno:
#   - Un array ARCHIVOS con los nombres de los archivos de copia
#     de seguridad
# ------------------------------------------------------------------------------
f_backup_list() {
	# Variables locales
	local dir_list="$A_LIST"
	local file_name
	local res

	# Cargar las lista de base de datos desde archivo list_db
	if [[ -f "$dir_list" ]]; then
		. "$dir_list"
	else
		f_gestion_logs "ebkp" "No se encontro el archivo db.lst"
		exit 1
	fi

	# Declaramos un array vacio denominado ARCHIVOS para guardar ahi los archivos
	declare -a ARCHIVOS

	# Inicializa la variable "num_rows"
	local num_rows=$N_ROWS

	for ((i = 1; i <= num_rows; i++)); do
		# Colocamos un nombre a la copia de segurida
		file_name="${mdb[$i, 5]}_$(date +%d-%m-%Y_%H.%M.%S).sql.gz"

		if [[ ${mdb["$i", 6]} = "pg" ]]; then
			# Ejecutamos DUMP de postgres y la copia de seguridad la colocamos en el directorio bkp
			PGPASSWORD="${mdb[$i, 2]}" pg_dump -h "${mdb[$i, 3]}" -U "${mdb[$i, 1]}" "${mdb[$i, 5]}" | gzip >"$DIR_H/$file_name"
			res=${?}
		else
			# Ejecutamos DUMP de MYSQL y la copia de seguridad la colocamos en el directorio bkp
			mysqldump --user="${mdb[$i, 1]}" --password="${mdb[$i, 2]}" --host="${mdb[$i, 3]}" --port="${mdb[$i, 4]}" "${mdb[$i, 5]}" | gzip >"$DIR_H/$file_name"
			res=${?}
		fi

		# Verificamos que la copia de seguridad se haya ejetutado correctamente
		if [[ $res -eq 0 ]]; then
			echo "Copia de seguridad de la base de datos ${mdb[$i, 5]} creada en $file_name" >>"$LOG_FILE"
			#llemanos el array de copias de seguridad
			ARCHIVOS+=("$file_name")
		else
			echo "Error al crear la copia de seguridad de la base de datos ${mdb[$i, 5]}" >>"$LOG_FILE"
		fi
	done
}

# BACKUP DESDE .CSV
# ------------------------------------------------------------------------------

# f_backup_csv
#
# Crea las copias de seguridad de las bases de datos que se encuentran en el archivo
# db_list.csv
#
# Parametros:
#   - Ninguno
#
# Retorno:
#   - Un array ARCHIVOS con los nombres de los archivos de copia de seguridad
# ------------------------------------------------------------------------------
f_backup_csv() {
	# Variables locales
	local usser_db       # usuario
	local type_db        # tipo de base de datos
	local pass_db        # contraseña
	local ip_server_db   # ip
	local port_server_db # puerto
	local name_db        # nombre de la base de datos
	local file_name=""   # nombre del archivo
	local ress           # resultado de la copia de seguridad

	# Verificamos que el archivo .csv exista
	if [[ -f "$A_CSV" ]]; then
		# Carga las credenciales desde el archivo CSV
		f_gestion_logs "tbkp" " Cargando credenciales desde el archivo db_list.csv" "INFO"
		# Itera a través del archivo CSV y muestra cada línea
		while IFS=';' read -r usser_db pass_db ip_server_db port_server_db name_db type_db; do
			# Nombre del archico de Back-Up
			file_name="$name_db""_$(date +%d-%m-%Y_%H.%M.%S).sql.gz"
			# Realizado el Back-Up por tipo de manejador de base de datos
			case "$type_db" in
			"mysql" | "mdb")
				# Ejecutamos DUMP de MYSQL y la copia de seguridad la colocamos en el directorio bkp
				mysqldump --user="$usser_db" --password="$pass_db" --host="$ip_server_db" --port="$port_server_db" "$name_db" | gzip >"$DIR_H/$file_name"
				ress=${?}
				;;
			"pg" | "postgres")
				# Ejecutamos DUMP de postgres y la copia de seguridad la colocamos en el directorio bkp
				PGPASSWORD="$pass_db" pg_dump -h "$ip_server_db" -U "$usser_db" "$name_db" | gzip >"$DIR_H/$file_name"
				ress=${?}
				;;
			*)
				f_gestion_logs "tbkp" "Error no definido el manejador de base de datos $name_db" "ERROR"
				;;
			esac

			# Verificamos que la copia de seguridad se haya ejetutado correctamente
			if [[ $ress -eq 0 ]]; then
				f_gestion_logs "tbkp" "Copia de seguridad de la base de datos $name_db creada en $file_name" "INFO"
			else
				f_gestion_logs "tbkp" "Error al crear la copia de seguridad de la base de datos $name_db" "ERROR"
			fi
		done <"$A_CSV"
	else
		f_gestion_logs "tbkp" "No se encontro el archivo $A_CSV" "ERROR"
	fi
}
# GENEREADOR DE RESPALDOS
# ------------------------------------------------------------------------------
# f_backup()
#
# Genera los respaldos de las bases de datos, crea el archivo de log y lo llena
# con los registros temporales, y llama a la funcion de respaldo seleccionada
# por el usuario.
#
# Parametros:
#   - Ninguno
#
# Retorno:
#   - Ninguno
# ------------------------------------------------------------------------------
f_backup() {
	# Variables locales
	local bkp_log_file=$(f_add_arch "$DIR_H" "$(date +%d%m%Y)-$hora.log") # Logs locales
	local status=0

	while [ "$status" -le 0 ]; do
		if [[ -f "$bkp_log_file" ]]; then

			# Limpiando archivo de Logs
			truncate -s 0 "$bkp_log_file"
			f_gestion_logs "ibkp" "Limpieza de registros del archivo de logs $bkp_log_file"

			# Estado de cración de archivo de logs
			status=1

			# Iniciando registrs de copias de seguridad
			echo "*********************** ESTRUCTURA DEL RESPALDO ***********************" >>"$bkp_log_file"

			# Cargado los Logs Temporales al archivo de Logs
			f_read_logs "bkp" >>"$bkp_log_file"

			# Iniciando el proceso de Respaldo
			{
				echo "*********************** INICIO DEL RESPALDO ***********************"
				echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Inicio de Proceso de Respaldo de Bases de datos"
			} >>"$bkp_log_file"

			# Defieniendo metodo de Back-Up
			case "$T_ARCH" in
			"csv")
				f_backup_csv
				# Captura de Logs
				f_read_logs "tmp" >>"$bkp_log_file"
				;;
			"lst")
				# TODO: Implementar esta funcionalidad
				# f_backup_list
				f_gestion_logs "tbkp" "Funcion no implementada" "WARNING"
				# Captura de Logs
				f_read_logs "tmp" >>"$bkp_log_file"
				;;
			*)
				f_gestion_logs "tbkp" "Metodo de obtencion de credenciales de acceso no definido" "ERROR"
				f_read_logs "tmp" >>"$bkp_log_file"
				;;
			esac
			{
				echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Fin de Proceso de Respaldo de Bases de datos"
				echo "*********************** FIN DE RESPALDO ***********************"
			} >>"$bkp_log_file"
		else
			# Creando archivo de Logs
			touch "$bkp_log_file"
			f_gestion_logs "wbkp" "Se ha creado el archivo de logs $bkp_log_file"

			# Stado de cración de archivo de logs
			status=0
		fi
	done

	# Mostrando Logs de Respaldos
	cat "$bkp_log_file"
}

# TODO: por implementar la copia de archivos a servidor remoto
# COPIA DE ARCHIVOS REMOTOS
#------------------------------------------------------------------------------
# f_copy_remote
#
# Copia los archivos de copia de seguridad a un equipo remoto.
#
# Parametros:
#   - Ninguno
#
# Retorno:
#   - Ninguno
#
# Variables locales:
#   dir_nfs: directorio a donde se copiaran los archivos de copia de seguridad
#   dir_origen: directorio de origen de los archivos de copia de seguridad
#
#------------------------------------------------------------------------------
# f_copy_remote() {
# 	# Variables locales
# 	local dir_nfs=$D_NFS
# 	local dir_origen="$DIR_ACTUAL/$DIR_BKP"

# 	# Cargado los Logs Temporales al archivo de Logs
# 	echo "#################### Copia a Equipos Remotos ####################" >>"$LOG_FILE"

# 	echo "***** Copia de los respaldo a una unidad NFS *****" >>"$LOG_FILE"
# 	# Comprobando la existencia del directorio destino
# 	if [[ -d $dir_nfs ]]; then
# 		# Enviando las copias de seguridad al directorio destino
# 		#rsync -uazhP -n "$dir_origen/" "$dir_nfs" >>"$LOG_FILE" 2>&1
# 		rsync -uazhP "$dir_origen/" "$dir_nfs" >>"$LOG_FILE" 2>&1
# 		# Validadno el envio
# 		local res=${?}
# 		if [[ $res -eq 0 ]]; then
# 			echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Copias de seguridad exitosa copiadas a $dir_nfs" >>"$LOG_FILE"
# 		else
# 			echo "[ERROR $(date +%Y-%m-%d:%H:%M)] La copia de seguridad a $dir_nfs a fallado" >>"$LOG_FILE"
# 			#exit 1
# 		fi
# 	fi

# 	echo "***** Copia de los respaldo a un equipo remoto *****" >>"$LOG_FILE"

# 	local copy_remote="${C_RMTE:-no}"
# 	case "$copy_remote" in
# 	yes)
# 		# Copiar las copias de seguridad al equipo remoto
# 		#sshpass -p "$REMOTE_PASS" rsync -avz --stats "$hora_dia" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/$ANIO_ACTUAL/$MES_ACTUAL/$DIA_ACTUAL/" >>"$LOG_FILE" 2>&1
# 		#rsync -uvazP -n -e 'ssh -p 22' "$dir_origen/" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/" >>"$LOG_FILE" 2>&1
# 		rsync -uvazP -e 'ssh -p 22' "$dir_origen/" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/" >>"$LOG_FILE" 2>&1
# 		local res=${?}
# 		if [[ $res -eq 0 ]]; then
# 			echo "[WARNING $(date +%Y-%m-%d:%H:%M)]Copias de seguridad exitosa copiadas a $REMOTE_HOST:$REMOTE_DIR/$ANIO_ACTUAL/$MES_ACTUAL/$DIA_ACTUAL/$hora" >>"$LOG_FILE"
# 		else
# 			echo "La copia de seguridad ha fallado" >>"$LOG_FILE"
# 			echo "[ERROR $(date +%Y-%m-%d:%H:%M)] La copia de seguridad a $REMOTE_HOST a fallado" >>"$LOG_FILE"
# 			#exit 1
# 		fi

# 		# Fin del registro
# 		echo "[WARNING $(date +%Y-%m-%d:%H:%M)]Fin del respaldo en fecha $(date +%d-%m-%Y_%H:%M:%S)" >>"$LOG_FILE"

# 		# Copiamos archivos log
# 		#sshpass -p "$REMOTE_PASS" scp "$LOG_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/$ANIO_ACTUAL/$MES_ACTUAL/$DIA_ACTUAL/$hora/" >>"$LOG_FILE"
# 		;;
# 	no)
# 		echo "[WARNING $(date +%Y-%m-%d:%H:%M)] No se copio a directorio remoto" >>"$LOG_FILE"
# 		;;
# 	*)
# 		echo "[ERROR $(date +%Y-%m-%d:%H:%M)] No se realiczo la copia de seguridad a $REMOTE_HOST " >>"$LOG_FILE"
# 		echo default
# 		;;
# 	esac
# }

# TODO: por implementar el envio de correos de notificaciones
# ENVIO DE CORREO
# ------------------------------------------------------------------------------
# ENVIA UN CORREO ELECTRÓNICO CON EL LOG DE LA EJECUCIÓN DEL SCRIPT
#
# Parámetros:
#   Ninguno
#
# Variables locales:
#   res: Código de estado devuelto por sendemail
#   remitente: Dirección de correo electrónico del remitente
#   smtp_servidor: Servidor SMTP del remitente
#   smtp_puerto: Puerto SMTP del remitente
#   smtp_usuario: Usuario del remitente para autenticar en el servidor SMTP
#   smtp_contrasena: Contraseña del remitente para autenticar en el servidor SMTP
#   destinatarios: Lista de direcciones de correo electrónico de destinatarios separadas por comas
#   asunto: Asunto del correo electrónico
#   cuerpo: Cuerpo del correo electrónico
#
# Devuelve:
#   Ninguno
#
# Modifica:
#   Ninguno
# ------------------------------------------------------------------------------
# f_email() {
# 	# Variables locales
#  	local res

# 	# Dirección de correo electrónico del remitente y servidor SMTP
# 	remitente="tucorreo@gmail.com"
# 	smtp_servidor="smtp.gmail.com"
# 	smtp_puerto=587
# 	smtp_usuario="tucorreo@gmail.com"
# 	smtp_contrasena="tucontrasena"

# 	# Lista de direcciones de correo electrónico de destinatarios (separadas por comas)
# 	destinatarios="destinatario1@example.com, destinatario2@example.com, destinatario3@example.com"

# 	# Asunto y cuerpo del correo electrónico
# 	asunto="Asunto del correo"
# 	cuerpo="Este es el contenido del correo."

# 	# Envía el correo electrónico a los destinatarios utilizando sendemail
# 	sendemail -f "$remitente" -t "$destinatarios" -u "$asunto" -m "$cuerpo" -s "$smtp_servidor:$smtp_puerto" -xu "$smtp_usuario" -xp "$smtp_contrasena"
# 	res=${?}

# 	# Verifica si el correo se envió exitosamente
# 	if [[ $res -eq 0 ]]; then
# 		echo "Correo enviado exitosamente a: $destinatarios"
# 	else
# 		echo "No se pudo enviar el correo."
# 	fi
# }

# ===============================================================================
# SCRIPT
# ===============================================================================
# Limpiando archivos temporales de Logs
truncate -s 0 $ERROR_BKP_LOG $WARN_BKP_LOG $INF_BKP_LOG $TEMP_BKP_LOG

# Limpiando la terminal
# clear

# Creando Directorio Raiz de Back-Up
DIR_O=$(f_add_dir "$DIR_ACTUAL" "$DIR_BKP")

# Creando Directorio Año de Back-Up
DIR_A=$(f_add_dir "$DIR_O" "$ANIO_ACTUAL")

# Creando Directorio Mes de Back-Up
DIR_M=$(f_add_dir "$DIR_A" "$MES_ACTUAL")

# Creando Directorio Dia de Back-Up
DIR_D=$(f_add_dir "$DIR_M" "$DIA_ACTUAL")

# Creando Directorio Hora de Back-Up
hora=$(f_time_day)
DIR_H=$(f_add_dir "$DIR_D" "$hora")

# Generando los Back-Up
f_backup

# f_read_logs "bkp"

# ===============================================================================
# FIN DEL SCRIPT
