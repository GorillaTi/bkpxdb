#!/usr/bin/env bash

# Autor: Jose Mendoaza Vargas
#      : Edmundo Cespedes A.
# Licencia: MIT
# NOMBRE: bkp_db (copia_seg)
# Version: 2.0.0
# FUNSION:
# Copia de Seguridad de bases de datos MYSQL MariaDn y PosrgreSQL

# Diclaimer:

# Copyright (c) 2024 Edmundo Cespedes A. <a.k.a. eksys>

# This software is provided under the MIT License.

# You can obtain a copy of the license at 
# https://opensource.org/licenses/MIT

# In summary, you are permitted to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software
# is furnished to do so, subject to the following conditions:

# You must include this copyright notice and this license in all copies or substantial 
# portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# Exit if any command fails
set -eou pipefail

# Directorio Actual
dir_actual=$(pwd)
# Iniciando Logs de Fatal Error
error_log="/var/log/error.log"

# ------------------------------------------------------------------------------
# SOURCES
# ------------------------------------------------------------------------------
# Cargar las variables de entorno desde el archivo .env
if [[ -f "$dir_actual/scripts/.conf" ]]; then
	. "$dir_actual/scripts/.conf"
else
	echo " [ERROR $(date +%Y-%m-%d:%H:%M)] El archivo $dir_actual/scripts/.conf no existe." >>"$error_log"
	exit 1
fi
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# VARIABLES
# ------------------------------------------------------------------------------
# Configuración del equipo remoto
remote_user=$R_USER
remote_host=$R_HOST
remote_dir=$R_DIR
remote_pass=$R_PASS

# Dia Actual, Mes Actual y año actual
dia_actual=$(date +%d)
mes_actual=$(date +%m)
anio_actual=$(date +%Y)
hora_actual=$(date +%H)

# Tipo de origen de archovo de datos de DB
t_arch="${1:-csv}"

# ubicacion archivos de datos de DB
#a_lst="$dir_actual/db.lst"
a_csv="$dir_actual/list/db_list.csv"

# Directorio BKP
dir_bkp="${D_BKP:-bkp_db}"

# Archivos de logs
tmp_log="/tmp/bkp_db.log"
log_file="/var//log_file.log"

# Directorios de trabajo
unset dir_a
unset dir_m
unset dir_d
unset dir_h
# FUNCIONES
# ------------------------------------------------------------------------------
# LECTURA DE ARCHIVOS DE LOGS
# ------------------------------------------------------------------------------
# f_cat_logs(activate)
# Muestra los archivos de logs (tmp, error y log_file)
# Si el parametro activate es "a" entonces muestra los logs
# Si el parametro activate es diferente a "a" no muestra los logs
# ------------------------------------------------------------------------------
f_cat_logs() {
	local activate=$1
	case $activate in
		"a")
			# Mostrando los archivos de logs
			if [[ -f $error_log ]]; then
				echo "################## ERROR LOGS ##################"
				cat "$error_log"
			fi
			if [[ -f $tmp_log ]]; then
				echo "################## TEMPORAL LOGS ##################"
				cat "$tmp_log"
			fi
			if [[ -f $log_file ]]; then
				echo "################## LOGS ##################"
				cat "$log_file"
			fi
			;;
		*)
			# No se activo la captura de Logs
			echo "No se activo la captura de Logs"
			;;
	esac
}

# SELECCIONA LA HORA DEL DIA
# ------------------------------------------------------------------------------
# f_time_day()
# Selecciona la hora del dia y determina si es
# 13:00 - Medio dia
# 19:00 - Media tarde
# 23:00 - Media noche
# Otro valor - Temporal
# ------------------------------------------------------------------------------
f_time_day() {
	local hora_dia
	case $hora_actual in
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
# ------------------------------------------------------------------------------
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
# ------------------------------------------------------------------------------
f_add_dir() {
	local dir_orig="$1"
	local dir_new="$2"

	# Verificando si el directorio origen existe
	if [[ -d $dir_orig ]]; then
		# Cargando la estructura del nuevo directorio
		local dir_add="$dir_orig/$dir_new"
		# Creando el directorio
		if [[ ! -d $dir_orig/$dir_new ]]; then
			# Creando el directorio
			mkdir -p "$dir_add"
			# Cargando la variable de estado
			local stts="$?"
			# Comprobando el resultado de la creacion del directorio
			if [[ $stts -eq 0 ]]; then
				# Si se crea el nuevo directorio, se registra el mensaje de log
				echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Directorio $dir_new creado en $dir_orig" >>"$tmp_log"
				echo "$dir_add" # Retornando la ruta completa del directorio creado
			else
				# Si no se crea el nuevo directorio, se registra el mensaje de log con el error
				echo "[ERROR $(date +%Y-%m-%d:%H:%M)] No se pudo crear el $dir_new." >>"$error_log"
				exit 1 # Termina la ejecucion del script
			fi
		else
			# Si el directorio ya existe, se registra el mensaje de log
			echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Directorio $dir_new existente en $dir_orig" >>"$tmp_log"
			echo "$dir_add" # Retornando la ruta completa del directorio existente
		fi
	else
		# Si el directorio origen no existe, se registra el mensaje de error
		echo "El directorio $dir_orig no existe"
		exit 1 # Termina la ejecucion del script
	fi
}

# CREADOR DE ARCHIVOS
f_add_arch() {
	local dir_dest="$1"
	local arch_new="$2"

	if [[ -d $dir_dest ]]; then
		# Cargando la estructura del nuevo archivo
		local arch_add="$dir_dest/$arch_new"
		# Creando el archivo
		if [[ ! -f $arch_add ]]; then
			# Creando el archivo
			touch "$arch_add"
			# Cargando la variable de estado
			local stts="$?"
			# Comprobando el resultado de la creacion archivo
			if [[ $stts -eq 0 ]]; then
				echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Archivo $arch_new creado en $dir_dest" >>"$tmp_log"
				echo "$arch_add"
			else
				echo "[ERROR $(date +%Y-%m-%d:%H:%M)] No se pudo crear $arch_new." >>"$error_log"
				exit 1
			fi
		else
			echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Archivo $arch_new existente en $dir_dest" >>"$tmp_log"
			echo "$arch_add"
		fi
	else
		echo "El directorio $dir_dest no existe"
		exit 1
	fi
}

# BACKUP DESDE DB.LIST
f_backup_list() {
	local filename
	local res

	# Cargar las lista de base de datos desde archivo list_db
	if [[ -f "$(pwd)/db.lst" ]]; then
		. "$(pwd)/db.lst"
	else
		echo "[ERROR $(date +%Y-%m-%d:%H:%M)] El archivo db.lst no existe." >>"$error_log"
		exit 1
	fi

	# Declaramos un array vacio denominado ARCHIVOS para guardar ahi los archivos
	declare -a ARCHIVOS

	# Inicializa la variable "num_rows"
	local num_rows=$N_ROWS

	for ((i = 1; i <= num_rows; i++)); do
		# Colocamos un nombre a la copia de segurida
		filename="${mdb[$i, 5]}_$(date +%d-%m-%Y_%H.%M.%S).sql.gz"

		if [[ ${mdb["$i", 6]} = "pg" ]]; then
			# Ejecutamos DUMP de postgres y la copia de seguridad la colocamos en el directorio bkp
			PGPASSWORD="${mdb[$i, 2]}" pg_dump -h "${mdb[$i, 3]}" -U "${mdb[$i, 1]}" "${mdb[$i, 5]}" | gzip >"$dir_h/$filename"
			res=${?}
		else
			# Ejecutamos DUMP de MYSQL y la copia de seguridad la colocamos en el directorio bkp
			mysqldump --user="${mdb[$i, 1]}" --password="${mdb[$i, 2]}" --host="${mdb[$i, 3]}" --port="${mdb[$i, 4]}" "${mdb[$i, 5]}" | gzip >"$dir_h/$filename"
			res=${?}
		fi

		# Verificamos que la copia de seguridad se haya ejetutado correctamente
		if [[ $res -eq 0 ]]; then
			echo "Copia de seguridad de la base de datos ${mdb[$i, 5]} creada en $filename" >>"$log_file"
			#llemanos el array de copias de seguridad
			ARCHIVOS+=("$filename")
		else
			echo "Error al crear la copia de seguridad de la base de datos ${mdb[$i, 5]}" >>"$log_file"
		fi
	done
}

# TODO : comprobar el funcionamiento
# BACKUP DESDE .CSV
f_backup_csv() {
	# Variables locales
	local v_usser
	local t_db
	local v_pass
	local v_ip
	local v_port
	local v_ndb
	local filename=""
	local ress
	# Forma 1
	#
	# Verificamos que el archivo .csv exista
	if [[ ! -f "$a_csv" ]]; then
		echo "[ERROR $(date +%Y-%m-%d:%H:%M)] El archivo db_list.csv no existe." >>"$error_log"
		exit 1
	fi

	# Itera a través del archivo CSV y muestra cada línea
	while IFS=';' read -r v_usser v_pass v_ip v_port v_ndb t_db; do
		# Nombre del archico de Back-Up
		filename="$v_ndb""_$(date +%d-%m-%Y_%H.%M.%S).sql.gz"
		# Realizado el Back-Up por tipo de manejador de base de datos
		case "$t_db" in
		"mysql" | "mdb")
			# Ejecutamos DUMP de MYSQL y la copia de seguridad la colocamos en el directorio bkp
			# TODO: comprobar el funcionamiento
			mysqldump --user="$v_usser" --password="$v_pass" --host="$v_ip" --port="$v_port" "$v_ndb" | gzip > "$dir_h/$filename"
			local ress=${?}
			;;
		"pg"|"postgres")
			# Ejecutamos DUMP de postgres y la copia de seguridad la colocamos en el directorio bkp
			PGPASSWORD="$v_pass" pg_dump -h "$v_ip" -U "$v_usser" "$v_ndb" | gzip > "$dir_h/$filename"
			local ress=${?}
			;;
		*)
			echo "[ERROR $(date +%Y-%m-%d:%H:%M)] Error no definido el manejador de base de datos $v_ndb" >>"$log_file"
			;;
		esac

		# Verificamos que la copia de seguridad se haya ejetutado correctamente
		if [[ $ress -eq 0 ]]; then
			echo "[WARNING $(date +%Y-%m-%d:%H:%M)]Copia de seguridad de la base de datos $v_ndb creada en $filename" >>"$log_file"
			#llemanos el array de copias de seguridad
		else
			echo "[ERROR $(date +%Y-%m-%d:%H:%M)] Error al crear la copia de seguridad de la base de datos $v_ndb" >>"$log_file"
		fi
	done <"$a_csv"

	# Forma 2
	#
	# Cargar las lista de base de datos desde archivo list_db
	#if [[ -f "$a_csv" ]]; then
	#	for i in $(cat "$a_csv"); do
	#		v_usser=$(echo "$i" | cut -d ';' -f 1)
	#		v_pass=$(echo "$i" | cut -d ';' -f 2)
	#		v_ip=$(echo "$i" | cut -d ';' -f 3)
	#		v_port=$(echo "$i" | cut -d ';' -f 4)
	#		v_ndb=$(echo "$i" | cut -d ';' -f 5)
	#		t_db=$(echo "$i" | cut -d ';' -f 6)
	#		filename="$v_ndb""_$(date +%d-%m-%Y_%H.%M.%S).sql.gz"
	#		case "$t_db" in
	#		"mysql" | "mdb")
	#			# Ejecutamos DUMP de MYSQL y la copia de seguridad la colocamos en el directorio bkp
	#			#mysqldump --user="$v_usser" --password="$v_pass" --host="$v_ip" --port="$v_port" "$v_ndb" | gzip >"$dir_h/$filename"
	#			;;
	#		pg)
	#			# Ejecutamos DUMP de postgres y la copia de seguridad la colocamos en el directorio bkp
	#			#PGPASSWORD="$v_pass" pg_dump -h "$v_ip" -U "$v_usser" "$v_ndb" | gzip >"$dir_h/$filename"
	#			;;
	#		*)
	#			echo default
	#			;;
	#		esac

	#		# Verificamos que la copia de seguridad se haya ejetutado correctamente
	#		if [[ "$?" -eq "0" ]]; then
	#			echo "Copia de seguridad de la base de datos $v_ndb creada en $DIA_DIR/$hora_dia/$filename" >>"$log_file"
	#			#llemanos el array de copias de seguridad
	#		else
	#			echo "Error al crear la copia de seguridad de la base de datos $v_ndb" >>"$log_file"
	#		fi
	#	done
	#else
	#	echo "[ERROR $(date +%Y-%m-%d:%H:%M)] El archivo db_list.csv no existe." >>"$error_log"
	#	exit 1
	#fi
}
# GENEREADOR DE RESPALDOS
f_backup() {
	# Creando archivo de Logs
	log_file=$(f_add_arch "$dir_h" "$(date +%d%m%Y)-$hora.log")

	# TEST limpiando archivo de Logs
	truncate -s 0 "$log_file"

	# Cargado los Logs Temporales al archivo de Logs
	echo "#################### Esquema Base  ####################" >>"$log_file"
	cat "$tmp_log" >>"$log_file"

	# Limpiando archivo de temporal de logs
	truncate -s 0 "$tmp_log"

	# Iniciando el proceso de Respaldo
	echo "#################### Registros del Respaldo ####################" >>"$log_file"
	echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Inicio de Proceso de Respaldo de Bases de datos" >>"$log_file"

	# Defieniendo metodo de Back-Up
	case "$t_arch" in
	"csv")
		f_backup_csv
		;;
	"lst")
		f_backup_list
		;;
	*)
		echo "[ERROR $(date +%Y-%m-%d:%H:%M)] No se seleccionaron medias de obtencion de credenciales de acceso a las Bases de Datos" >>"$error_log"
		;;
	esac
	echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Fin de Proceso de Respaldo de Bases de datos" >>"$log_file"
}

# COPIA DE ARCHIVOS REMOTOS
f_copy_remote() {
	local dir_nfs=$D_NFS
	local dir_origen="$dir_actual/$dir_bkp"

	echo "#################### Copia a Equipos Remotos ####################" >>"$log_file"

	echo "***** Copia de los respaldo a una unidad NFS *****" >>"$log_file"
	# Comprobando la existencia del directorio destino
	if [[ -d $dir_nfs ]]; then
		# Enviando las copias de seguridad al directorio destino
		#rsync -uazhP -n "$dir_origen/" "$dir_nfs" >>"$log_file" 2>&1
		rsync -uazhP "$dir_origen/" "$dir_nfs" >>"$log_file" 2>&1
		# Validadno el envio
		local res=${?}
		if [[ $res -eq 0 ]]; then
			echo "[WARNING $(date +%Y-%m-%d:%H:%M)] Copias de seguridad exitosa copiadas a $dir_nfs" >>"$log_file"
		else
			echo "[ERROR $(date +%Y-%m-%d:%H:%M)] La copia de seguridad a $dir_nfs a fallado" >>"$log_file"
			#exit 1
		fi
	fi

	echo "***** Copia de los respaldo a un equipo remoto *****" >>"$log_file"

	local copy_remote="${C_RMTE:-no}"
	case "$copy_remote" in
	yes)
		# Copiar las copias de seguridad al equipo remoto
		#sshpass -p "$remote_pass" rsync -avz --stats "$hora_dia" "$remote_user@$remote_host:$remote_dir/$anio_actual/$mes_actual/$dia_actual/" >>"$log_file" 2>&1
		#rsync -uvazP -n -e 'ssh -p 22' "$dir_origen/" "$remote_user@$remote_host:$remote_dir/" >>"$log_file" 2>&1
		rsync -uvazP -e 'ssh -p 22' "$dir_origen/" "$remote_user@$remote_host:$remote_dir/" >>"$log_file" 2>&1
		local res=${?}
		if [[ $res -eq 0 ]]; then
			echo "[WARNING $(date +%Y-%m-%d:%H:%M)]Copias de seguridad exitosa copiadas a $remote_host:$remote_dir/$anio_actual/$mes_actual/$dia_actual/$hora" >>"$log_file"
		else
			echo "La copia de seguridad ha fallado" >>"$log_file"
			echo "[ERROR $(date +%Y-%m-%d:%H:%M)] La copia de seguridad a $remote_host a fallado" >>"$log_file"
			#exit 1
		fi

		# Fin del registro
		echo "[WARNING $(date +%Y-%m-%d:%H:%M)]Fin del respaldo en fecha $(date +%d-%m-%Y_%H:%M:%S)" >>"$log_file"

		# Copiamos archivos log
		#sshpass -p "$remote_pass" scp "$log_file" "$remote_user@$remote_host:$remote_dir/$anio_actual/$mes_actual/$dia_actual/$hora/" >>"$log_file"
		;;
	no)
		echo "[WARNING $(date +%Y-%m-%d:%H:%M)] No se copio a directorio remoto" >>"$log_file"
		;;
	*)
		echo "[ERROR $(date +%Y-%m-%d:%H:%M)] No se realiczo la copia de seguridad a $remote_host " >>"$log_file"
		echo default
		;;
	esac
}

# ENVIO DE CORREO
f_email() {
	local res

	# Dirección de correo electrónico del remitente y servidor SMTP
	remitente="tucorreo@gmail.com"
	smtp_servidor="smtp.gmail.com"
	smtp_puerto=587
	smtp_usuario="tucorreo@gmail.com"
	smtp_contrasena="tucontrasena"

	# Lista de direcciones de correo electrónico de destinatarios (separadas por comas)
	destinatarios="destinatario1@example.com, destinatario2@example.com, destinatario3@example.com"

	# Asunto y cuerpo del correo electrónico
	asunto="Asunto del correo"
	cuerpo="Este es el contenido del correo."

	# Envía el correo electrónico a los destinatarios utilizando sendemail
	sendemail -f "$remitente" -t "$destinatarios" -u "$asunto" -m "$cuerpo" -s "$smtp_servidor:$smtp_puerto" -xu "$smtp_usuario" -xp "$smtp_contrasena"
	res=${?}

	# Verifica si el correo se envió exitosamente
	if [[ $res -eq 0 ]]; then
		echo "Correo enviado exitosamente a: $destinatarios"
	else
		echo "No se pudo enviar el correo."
	fi
}
# ------------------------------------------------------------------------------
# SCRIPT
# ------------------------------------------------------------------------------
# Limpiando archivo de temporal de logs
truncate -s 0 "$tmp_log"

# Creando archivo de Logs de Error
error_log=$(f_add_arch "$dir_actual" "error.log")

# Creando Directorio Raiz de Back-Up
dir_o=$(f_add_dir "$dir_actual" "$dir_bkp")

# Creando Directorio Año de Back-Up
dir_a=$(f_add_dir "$dir_o" "$anio_actual")

# Creando Directorio Mes de Back-Up
dir_m=$(f_add_dir "$dir_a" "$mes_actual")

# Creando Directorio Dia de Back-Up
dir_d=$(f_add_dir "$dir_m" "$dia_actual")

# Creando Directorio Hora de Back-Up
hora=$(f_time_day)
dir_h=$(f_add_dir "$dir_d" "$hora")

# Generando los Back-Up
f_backup

# Envio de Back-Up a los sistemas de respaldo
f_copy_remote

# Captura de Logs
f_cat_logs "a"
