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
processor=$(uname -p)

# Obtener unidades y sus capacidades
lsblk >> "OUT_Drives_$fecha.txt"

# Función para mostrar información con color
mostrar_info() {
    printf "\e[0;33m $1 \e[0m\n"
}

# Función para obtener la lista de usuarios en /home
obtener_usuarios() {
    usuarios=($(ls /home))
}

# Función para volcar el historial de cada usuario en un archivo
volcar_historial() {
    local usuario="$1"
    local archivo_salida="OUT_history_${usuario}_${fecha}.txt"

    if [ -f "/home/$usuario/.bash_history" ]; then
        cat "/home/$usuario/.bash_history" > "$archivo_salida"
        echo "Historial de $usuario guardado en $archivo_salida"
    else
        echo "No se encontró historial para $usuario"
    fi
}

# Definir Fecha
fecha=$(date +"%Y%m%d_%H%M%S")

# Obtener la ruta del script
script_dir=$(dirname "$(readlink -f "$0")")

# Crear directorio si no existe
mkdir -p "$script_dir/$hostname"
path="$script_dir/$hostname"

# Archivo de salida único
output_file="$path/Full_report_$fecha.txt"

# Redirigir la salida a un archivo
exec > "$output_file" 2>&1

# Mostrar información inicial en el archivo
mostrar_info "Bienvenido a la auditoría de seguridad de tu máquina Linux:"
mostrar_info "Hostname: $hostname"
mostrar_info "IPv4: $ipv4"
mostrar_info "IPv6: $ipv6"
mostrar_info "Release del kernel: $kernel"
mostrar_info "Tipo de procesador: $processor"

# Ejecutar las acciones automáticamente
mostrar_info "\nEjecutando auditoría automáticamente..."

# Lista de usuarios actualmente conectados
mostrar_info "\nLista de usuarios actualmente conectados"
w

# Servicios en ejecución
mostrar_info "\nServicios en ejecución"
service --status-all | grep "+"

# Conexiones activas a Internet y puertos abiertos
mostrar_info "\nConexiones activas a Internet y puertos abiertos"
netstat -natp

# Espacio disponible en disco
mostrar_info "\nEspacio disponible en disco"
df -h

# Historial de comandos
mostrar_info "\nHistorial de comandos"
history

# Procesos en ejecución
mostrar_info "\nProcesos en ejecución"
ps -a

# Políticas de contraseñas
mostrar_info "\nPolíticas de contraseñas"
cat /etc/pam.d/common-password

# Lista de nombres de usuarios
mostrar_info "\nLista de nombres de usuarios"
cut -d: -f1 /etc/passwd

# Contraseñas nulas
mostrar_info "\nContraseñas nulas"
usuarios="$(cut -d: -f 1 /etc/passwd)"
for x in $usuarios; do
    passwd -S $x | grep "NP"
done

# Intentos de inicio de sesión fallidos
mostrar_info "\nIntentos de inicio de sesión fallidos"
grep --color "failure" /var/log/auth.log

# Usuarios con CAT al shadow
mostrar_info "\nUsuarios con CAT al shadow"
cat /var/log/secure* | grep "cat /etc/shadow"

# bash_history de los usuarios
mostrar_info "\nbash_history de los usuarios"
obtener_usuarios
for usuario in "${usuarios[@]}"; do
    volcar_historial "$usuario"
done

mostrar_info "\n¡Auditoría completada! Los resultados se han guardado en: $output_file"
