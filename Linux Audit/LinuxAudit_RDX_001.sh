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
            read -p "Por favor, ingresa la ruta para guardar la salida: " -r path

            # Verificar si la ruta es válida
            if [ -d "$path" ]; then
                output_file="$path/LinuxAudit.txt"
                break
            else
                echo "Ruta no válida. Por favor, ingresa un directorio válido."
            fi
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

# ------------------------------------------------------
# Inicio de la auditoría

# Ejemplo:
mostrar_info "1. Información del Kernel de Linux//////"
uname -a >> "$output_file"
mostrar_info "2. Información del usuario actual y ID//////"
whoami >> "$output_file"
id >> "$output_file"
mostrar_info "3. Información de la distribución de Linux///// "
lsb_release -a >> "$output_file"
mostrar_info "4. Lista de usuarios actualmente conectados///// "
w >> "$output_file"
mostrar_info "5. Información de tiempo de actividad de $HOSTNAME ///// "
uptime >> "$output_file"
mostrar_info "6. Servicios en ejecución///// "
service --status-all | grep "+" >> "$output_file"
mostrar_info "7. Conexiones activas a Internet y puertos abiertos///// "
netstat -natp >> "$output_file"
mostrar_info "8. Espacio disponible en disco///// "
df -h >> "$output_file"
mostrar_info "9. Información de memoria///// "
free -h >> "$output_file"
mostrar_info "10. Historial de comandos///// "
history >> "$output_file"
mostrar_info "11. Interfaces de red///// "
ifconfig -a >> "$output_file"
mostrar_info "12. Información de iptables///// "
iptables -L -n -v >> "$output_file"
mostrar_info "13. Procesos en ejecución///// "
ps -a >> "$output_file"
mostrar_info "14. Configuración de SSH///// "
cat /etc/ssh/sshd_config >> "$output_file"
mostrar_info "15. Lista de todos los paquetes instalados///// "
apt-cache pkgnames >> "$output_file"
mostrar_info "16. Parámetros de red///// "
cat /etc/sysctl.conf >> "$output_file"
mostrar_info "17. Políticas de contraseñas///// "
cat /etc/pam.d/common-password >> "$output_file"
mostrar_info "18. Archivo de lista de fuentes de paquetes///// "
cat /etc/apt/sources.list >> "$output_file"
mostrar_info "19. Verificación de dependencias rotas///// "
apt-get check >> "$output_file"
mostrar_info "20. Mensaje de banner MOTD///// "
cat /etc/motd >> "$output_file"
mostrar_info "21. Lista de nombres de usuarios///// "
cut -d: -f1 /etc/passwd >> "$output_file"
mostrar_info "22. Contraseñas nulas///// "
usuarios="$(cut -d: -f 1 /etc/passwd)"
for x in $usuarios; do
    passwd -S $x | grep "NP" >> "$output_file"
done
mostrar_info "23. Tabla de enrutamiento IP///// "
route >> "$output_file"
mostrar_info "24. Mensajes del kernel///// "
dmesg >> "$output_file"
mostrar_info "25. Paquetes que se pueden actualizar///// "
apt list --upgradeable >> "$output_file"
mostrar_info "26. Información de CPU/Sistema///// "
cat /proc/cpuinfo >> "$output_file"
mostrar_info "27. TCP wrappers///// "
cat /etc/hosts.allow >> "$output_file"
mostrar_info "27.1 TCP wrappers (denegaciones)///// "
cat /etc/hosts.deny >> "$output_file"
mostrar_info "28. Intentos de inicio de sesión fallidos///// "
grep --color "failure" /var/log/auth.log >> "$output_file"

mostrar_info "29. Usuarios con CAT al shadow///// "
cat /etc/secure | grep "cat /etc/shadow" >> "$output_file"


# Fin del script
exit 0
