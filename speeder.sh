#!/bin/bash

# Solicitar elevación de privilegios si no se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Este script requiere privilegios de superusuario. Solicitando elevación..."
    exec sudo "$0" "$@"
fi

# Mostrar la configuración de red actual
echo "Obteniendo información de configuración de red actual..."
ip addr show

# Obtener el adaptador de red activo (con IP), ignorando 'lo' y adaptadores inalámbricos
active_iface=""
for iface in $(ip -o link show | awk -F': ' '{print $2}'); do
    if [[ "$iface" != "lo" ]]; then
        if ip addr show "$iface" | grep -q "inet "; then
            if [ ! -d "/sys/class/net/$iface/wireless" ]; then
                active_iface=$iface
                break
            fi
        fi
    fi
done

if [ -z "$active_iface" ]; then
    echo "No se encontró un adaptador de red compatible (con cable y activo)."
    exit 1
else
    echo "Adaptador de red activo encontrado: $active_iface"
fi

# Verificar si 'ethtool' está instalado, si no, instalarlo
if ! command -v ethtool &>/dev/null; then
    echo "'ethtool' no está instalado. Instalándolo..."
    if ! apt-get update || ! apt-get install -y ethtool; then
        echo "Error: No se pudo instalar 'ethtool'. Verifique su conexión a Internet y repositorios de APT."
        exit 1
    fi
fi

# Verificar el estado de GRO y habilitar si está desactivado
gro_status=$(ethtool -k "$active_iface" 2>/dev/null | grep "generic-receive-offload" | awk '{print $2}')
if [ "$gro_status" != "on" ]; then
    echo "Habilitando Generic Receive Offload (GRO) para $active_iface..."
    if ! ethtool -K "$active_iface" gro on; then
        echo "Error: No se pudo habilitar GRO en $active_iface."
    else
        echo "GRO habilitado correctamente para $active_iface."
    fi
else
    echo "Generic Receive Offload (GRO) ya está habilitado para $active_iface."
fi
