#!/bin/bash

# Detener ejecución en caso de error
set -e

# Solicitar elevación de privilegios si no se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Este script requiere privilegios de superusuario. Solicitando elevación..."
    exec sudo "$0" "$@"
fi

# Verificar si pkg está instalado y configurado
if ! command -v pkg &>/dev/null; then
    echo "Error: El gestor de paquetes 'pkg' no está instalado. Por favor, instálelo y configúrelo."
    exit 1
fi

# Mostrar la configuración de red actual
echo "Obteniendo información de configuración de red actual..."
ifconfig

# Obtener el adaptador de red activo con dirección IP, excluyendo 'lo' y adaptadores inalámbricos
echo "Buscando adaptador de red activo..."
active_iface=$(ifconfig -l | awk '{print $1}' | while read iface; do
    if ifconfig "$iface" | grep -q "inet "; then
        if ! ifconfig "$iface" | grep -q "wlan"; then  # Excluir interfaces inalámbricas
            echo "$iface"
            break
        fi
    fi
done)

if [ -z "$active_iface" ]; then
    echo "No se encontró un adaptador de red compatible (con cable y activo)."
    exit 1
else
    echo "Adaptador de red activo encontrado: $active_iface"
fi

# Verificar si 'ethtool' está instalado, si no, instalarlo
if ! command -v ethtool &>/dev/null; then
    echo "'ethtool' no está instalado. Instalándolo..."
    if ! pkg update || ! pkg install -y ethtool; then
        echo "Error: No se pudo instalar 'ethtool'. Verifique su conexión a Internet y repositorios de pkg."
        exit 1
    fi
fi

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
