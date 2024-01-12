#!/bin/bash

# Obtener hostname
hostname=$(hostname)

# Obtener la dirección IPv4 y guardarla en una variable
ipv4=$(hostname -I | awk '{print $1}')

# Obtener la dirección IPv6 y guardarla en una variable
ipv6=$(hostname -I | awk '{print $2}')

# Obtener release del kernel
kernel=$(uname -r)

# Obtener tipo de procesador
kernel=$(uname -p)

# Obtener tipo de procesador
kernel=$(uname -p)

# Obtener unidades y sus capacidades
lsblk >> "$path/OUT_Drives_$fecha.txt"



# Función para mostrar encabezados
mostrar_encabezado() {
    printf "###############################################\n"
}

# Función para mostrar información con color
mostrar_info() {
    printf "\e[0;33m $1 \e[0m\n"
}

# Función para manejar Ctrl+C
ctrl_c() {
    echo "**Has presionado Ctrl+C... Saliendo"
    exit 0
}

trap ctrl_c INT

# Obtener la ruta del script
script_dir=$(dirname "$(readlink -f "$0")")

# Definir Fecha
fecha=$(date +"%Y%m%d_%H%M%S")

# Función para limpiar la pantalla
limpiar_pantalla() {
    tput clear
}

# Mostrar el encabezado del script
limpiar_pantalla
mostrar_encabezado
echo "Bienvenido a la auditoría de seguridad de tu máquina Linux:"
mostrar_encabezado

# Preguntar al usuario si desea guardar la salida
while true; do
    read -p "¿Quieres guardar la salida en archivo? [S/N] " -r output
    case ${output:0:1} in
        s|S)
            read -p "Por favor, ingresa la ruta para guardar la salida (deja en blanco para el mismo directorio): " -r path

            # Verificar si la ruta es válida
            if [ -z "$path" ]; then
				mkdir -p "$script_dir/$hostname"
                path="$script_dir/$hostname"

            elif [ ! -d "$path" ]; then
                echo "El directorio no existe. Se creará en el mismo directorio que el script."
				path_temp="$path"
				mkdir -p "$path_temp/$hostname"
                path="$path_temp/$hostname"
            fi
y
            output_file_01="$path/OUT_ConnectedUsers_$fecha.txt"
			output_file_02="$path/OUT_RuningServices_$fecha.txt"
			output_file_03="$path/OUT_ActiveConnections_$fecha.txt"
			output_file_04="$path/OUT_DiskFreeSpace_$fecha.txt"
			output_file_05="$path/OUT_History_$fecha.txt"
            output_file_06="$path/OUT_ActiveProcess_$fecha.txt"
			output_file_07="$path/OUT_PasswordPolicies_$fecha.txt"
			output_file_08="$path/OUT_UserList_$fecha.txt"
			output_file_09="$path/OUT_NULL_Passwords_$fecha.txt"
			output_file_10="$path/OUT_FailSessionStart_$fecha.txt"
			output_file_11="$path/OUT_Cat_to_Shadow_$fecha.txt"
            break
            ;;
        n|N)
            echo "OK, no se guardará ningún archivo."
            break
            ;;
        *)
            echo "Por favor, ingresa S o N."
            ;;
    esac
done


# Función para obtener la lista de usuarios en /home
obtener_usuarios() {
    usuarios=($(ls /home))
}


# Función para volcar el historial de cada usuario en un archivo
volcar_historial() {
    local usuario="$1"
    local archivo_salida="$path/OUT_history_${usuario}_${fecha}.txt"

    if [ -f "/home/$usuario/.bash_history" ]; then
        cat "/home/$usuario/.bash_history" > "$archivo_salida"
        echo "Historial de $usuario guardado en $archivo_salida"
    else
        echo "No se encontró historial para $usuario"
    fi
}

# Menú interactivo
limpiar_pantalla
while true; do
    echo -e "\nSeleccione una opción de auditoría:"
    echo "1. Lista de usuarios actualmente conectados"
    echo "2. Servicios en ejecución"
    echo "3. Conexiones activas a Internet y puertos abiertos"
    echo "4. Espacio disponible en disco"
    echo "5. Historial de comandos"
    echo "6. Procesos en ejecución"
    echo "7. Políticas de contraseñas"
    echo "8. Lista de nombres de usuarios"
    echo "9. Contraseñas nulas"
    echo "10. Intentos de inicio de sesión fallidos"
    echo "11. Usuarios con CAT al shadow"
    echo "12. bash_history de los usuarios"
    echo "13. SALIR"

    read -p "Ingrese el número de la opción que desea ejecutar: " opcion

    case $opcion in
        1) mostrar_info "Lista de usuarios actualmente conectados"; w >> "$output_file_01" 
		limpiar_pantalla		
		;;
        2) mostrar_info "Servicios en ejecución"; service --status-all | grep "+" >> "$output_file_01"
		limpiar_pantalla		
		;;
        3) mostrar_info "Conexiones activas a Internet y puertos abiertos"; netstat -natp >> "$output_file_03"
		limpiar_pantalla		
		;;
        4) mostrar_info "Espacio disponible en disco"; df -h >> "$output_file_04"
		limpiar_pantalla		
		;;
        5) mostrar_info "Historial de comandos"; history >> "$output_file_05"
		limpiar_pantalla		
		;;
        6) mostrar_info "Procesos en ejecución"; ps -a >> "$output_file_06"
		limpiar_pantalla		
		;;
        7) mostrar_info "Políticas de contraseñas"; cat /etc/pam.d/common-password >> "$output_file_07"
		limpiar_pantalla		
		;;
        8) mostrar_info "Lista de nombres de usuarios"; cut -d: -f1 /etc/passwd >> "$output_file_08"
		limpiar_pantalla		
		;;
        9) mostrar_info "Contraseñas nulas"; usuarios="$(cut -d: -f 1 /etc/passwd)"; for x in $usuarios; do passwd -S $x | grep "NP" >> "$output_file_09"; done
		limpiar_pantalla		
		;;
        10) mostrar_info "Intentos de inicio de sesión fallidos"; grep --color "failure" /var/log/auth.log >> "$output_file_10"
		limpiar_pantalla		
		;;
        11) mostrar_info "Usuarios con CAT al shadow"; cat /var/log/secure* | grep "cat /etc/shadow" >> "$output_file_11"
		limpiar_pantalla		
		;;

		12) mostrar_info "bash_history de los usuarios"
		limpiar_pantalla
		# Obtener la lista de usuarios
		obtener_usuarios

		# Iterar sobre la lista de usuarios y volcar el historial
		for usuario in "${usuarios[@]}"; do
			volcar_historial "$usuario"
		done
		;;


        13) mostrar_info "Saliendo"; exit 0
		limpiar_pantalla		
		;;
        *) echo "Opción no válida. Por favor, ingrese un número válido." ;;
    esac
done
