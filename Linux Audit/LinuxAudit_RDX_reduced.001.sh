#!/bin/bash

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

# Limpiar la terminal
tput clear

# Mostrar el encabezado del script
mostrar_encabezado
echo "Bienvenido a la auditoría de seguridad de tu máquina Linux:"
mostrar_encabezado

# Preguntar al usuario si desea guardar la salida
while true; do
    read -p "¿Quieres guardar la salida? [S/N] " -r output
    case ${output:0:1} in
        s|S)
            read -p "Por favor, ingresa la ruta para guardar la salida (deja en blanco para el mismo directorio): " -r path

            # Verificar si la ruta es válida
            if [ -z "$path" ]; then
                path="$script_dir"
            elif [ ! -d "$path" ]; then
                echo "El directorio no existe. Se creará en el mismo directorio que el script."
                path="$script_dir"
            fi

            output_file="$path/LinuxAudit.txt"
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

# Crear el archivo de salida
if [ -n "$output_file" ]; then
    touch "$output_file"
fi

# Menú interactivo
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
    echo "12. Salir"

    read -p "Ingrese el número de la opción que desea ejecutar: " opcion

    case $opcion in
        1) mostrar_info "Lista de usuarios actualmente conectados"; w >> "$output_file" ;;
        2) mostrar_info "Servicios en ejecución"; service --status-all | grep "+" >> "$output_file" ;;
        3) mostrar_info "Conexiones activas a Internet y puertos abiertos"; netstat -natp >> "$output_file" ;;
        4) mostrar_info "Espacio disponible en disco"; df -h >> "$output_file" ;;
        5) mostrar_info "Historial de comandos"; history >> "$output_file" ;;
        6) mostrar_info "Procesos en ejecución"; ps -a >> "$output_file" ;;
        7) mostrar_info "Políticas de contraseñas"; cat /etc/pam.d/common-password >> "$output_file" ;;
        8) mostrar_info "Lista de nombres de usuarios"; cut -d: -f1 /etc/passwd >> "$output_file" ;;
        9) mostrar_info "Contraseñas nulas"; usuarios="$(cut -d: -f 1 /etc/passwd)"; for x in $usuarios; do passwd -S $x | grep "NP" >> "$output_file"; done ;;
        10) mostrar_info "Intentos de inicio de sesión fallidos"; grep --color "failure" /var/log/auth.log >> "$output_file" ;;
        11) mostrar_info "Usuarios con CAT al shadow"; cat /etc/secure | grep "cat /etc/shadow" >> "$output_file" ;;
        12) mostrar_info "Saliendo"; exit 0 ;;
        *) echo "Opción no válida. Por favor, ingrese un núm
