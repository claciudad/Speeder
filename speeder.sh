#!/bin/bash

# Detener ejecución en caso de error
set -e

# Solicitar elevación de privilegios si no se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script requiere privilegios de superusuario. Solicitando elevación..."
    exec sudo "$0" "$@"
fi

# Función para preguntar si se desea instalar una dependencia
instalar_dependencia() {
    local dependencia=$1
    local mensaje=$2
    local comando_instalacion=$3

    if ! command -v "$dependencia" &>/dev/null; then
        echo "$mensaje"
        read -p "¿Deseas instalar $dependencia? (s/n): " respuesta
        if [[ "$respuesta" =~ ^[sS]$ ]]; then
            eval "$comando_instalacion"
            if ! command -v "$dependencia" &>/dev/null; then
                echo "Error: No se pudo instalar $dependencia. Verifica tu conexión a Internet o repositorios."
                exit 1
            fi
        else
            echo "$dependencia no está instalado. El script no puede continuar."
            exit 1
        fi
    fi
}

# Verificar el gestor de paquetes según la distribución
if command -v apt-get &>/dev/null; then
    PACKAGE_MANAGER="apt-get"
elif command -v dnf &>/dev/null; then
    PACKAGE_MANAGER="dnf"
elif command -v pacman &>/dev/null; then
    PACKAGE_MANAGER="pacman"
elif command -v pkg &>/dev/null; then
    PACKAGE_MANAGER="pkg"
else
    echo "Error: No se pudo detectar el gestor de paquetes. Este script soporta apt-get, dnf, pacman o pkg."
    exit 1
fi

# Verificar e instalar 'ifconfig' o 'ip' si no están disponibles
if ! command -v ip &>/dev/null && ! command -v ifconfig &>/dev/null; then
    echo "Ni 'ip' ni 'ifconfig' están instalados. Se requiere al menos uno de ellos para continuar."
    instalar_dependencia "ip" "'ip' no está instalado. Se recomienda instalar 'iproute2'." "$PACKAGE_MANAGER install -y iproute2"
fi

# Mostrar la configuración de red actual
echo "Obteniendo información de configuración de red actual..."
if command -v ip &>/dev/null; then
    ip addr show
else
    ifconfig
fi

# Obtener el adaptador de red activo con dirección IP, excluyendo 'lo' y adaptadores inalámbricos
echo "Buscando adaptador de red activo..."
if command -v ip &>/dev/null; then
    active_iface=$(ip -o link show | awk -F': ' '{print $2}' | while read iface; do
        if [[ "$iface" != "lo" ]] && ! [[ "$iface" =~ ^wlan ]]; then  # Excluir 'lo' e interfaces inalámbricas
            if ip addr show "$iface" | grep -q "inet "; then
                echo "$iface"
                break
            fi
        fi
    done)
else
    active_iface=$(ifconfig -l | awk '{print $1}' | while read iface; do
        if [[ "$iface" != "lo" ]] && ! [[ "$iface" =~ ^wlan ]]; then  # Excluir 'lo' e interfaces inalámbricas
            if ifconfig "$iface" | grep -q "inet "; then
                echo "$iface"
                break
            fi
        fi
    done)
fi

if [ -z "$active_iface" ]; then
    echo "No se encontró un adaptador de red compatible (con cable y activo)."
    exit 1
else
    echo "Adaptador de red activo encontrado: $active_iface"
fi

# Verificar e instalar 'ethtool' si no está instalado
instalar_dependencia "ethtool" "'ethtool' no está instalado. Es necesario para gestionar parámetros avanzados de red." "$PACKAGE_MANAGER install -y ethtool"

# Verificar si ethtool es compatible con la interfaz seleccionada
if ! ethtool "$active_iface" &>/dev/null; then
    echo "Advertencia: 'ethtool' no es compatible con la interfaz $active_iface. No se pueden gestionar parámetros avanzados."
    exit 1
fi

# Verificar el estado de GRO y habilitar si está desactivado
gro_status=$(ethtool -k "$active_iface" 2>/dev/null | grep "generic-receive-offload" | awk '{print $2}')
if [ "$gro_status" != "on" ]; then
    echo "Habilitando Generic Receive Offload (GRO) para $active_iface..."
    if ! ethtool -K "$active_iface" gro on; then
        echo "Error: No se pudo habilitar GRO en $active_iface."
        exit 1
    else
        echo "GRO habilitado correctamente para $active_iface."
    fi
else
    echo "Generic Receive Offload (GRO) ya está habilitado para $active_iface."
fi

# Manejo de señales para limpieza en caso de interrupción
trap "echo 'Script interrumpido. Realizando limpieza...'; exit 1" SIGINT SIGTERM
