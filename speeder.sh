#!/bin/bash

# Solicitar elevación de privilegios si no se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "Este script requiere privilegios de superusuario. Solicitando elevación..."
    exec sudo "$0" "$@"
    exit
fi

# Mostrar la configuración de red actual
echo "Obteniendo información de configuración de red actual..."
ip addr show

# Obtener el adaptador de red activo (con IP) que no sea inalámbrico
active_iface=""
for iface in $(ip -o link show | awk -F': ' '{print $2}'); do
    # Verificar si la interfaz está activa y tiene una dirección IP
    if ip addr show "$iface" | grep -q "inet "; then
        # Verificar si la interfaz es inalámbrica
        if [ ! -d "/sys/class/net/$iface/wireless" ]; then
            active_iface=$iface
            break
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
if ! command -v ethtool &> /dev/null; then
    echo "'ethtool' no está instalado. Instalándolo..."
    apt-get update
    apt-get install -y ethtool
fi

# Verificar y habilitar características de offload si es necesario
# En Linux, se pueden ajustar características como GRO, GSO, etc.

# Verificar el estado de GRO (Generic Receive Offload)
gro_status=$(ethtool -k "$active_iface" 2>/dev/null | grep "generic-receive-offload" | awk '{print $2}')
if [ "$gro_status" != "on" ]; then
    echo "Habilitando Generic Receive Offload (GRO) para $active_iface..."
    ethtool -K "$active_iface" gro on
else
    echo "Generic Receive Offload (GRO) ya está habilitado para $active_iface."
fi

# Verificar y establecer ajuste automático de TCP (equivalente a 'Receive Window Auto-Tuning Level')
auto_tuning=$(sysctl -n net.ipv4.tcp_window_scaling)
if [ "$auto_tuning" -ne 1 ]; then
    echo "Habilitando ajuste automático de ventana de TCP (tcp_window_scaling)..."
    sysctl -w net.ipv4.tcp_window_scaling=1
    # Para hacer persistente, agregar a /etc/sysctl.conf
    if ! grep -q "net.ipv4.tcp_window_scaling=1" /etc/sysctl.conf; then
        echo "net.ipv4.tcp_window_scaling=1" >> /etc/sysctl.conf
    fi
else
    echo "El ajuste automático de ventana de TCP ya está habilitado."
fi

# Verificar y configurar el proveedor de congestión TCP
current_cc=$(sysctl -n net.ipv4.tcp_congestion_control)
desired_cc="cubic" # 'ctcp' no es común en Linux; 'cubic' es predeterminado

if [ "$current_cc" != "$desired_cc" ]; then
    echo "Estableciendo proveedor de congestión TCP a '$desired_cc'..."
    sysctl -w net.ipv4.tcp_congestion_control="$desired_cc"
    # Para hacer persistente, agregar a /etc/sysctl.conf
    if ! grep -q "net.ipv4.tcp_congestion_control=$desired_cc" /etc/sysctl.conf; then
        echo "net.ipv4.tcp_congestion_control=$desired_cc" >> /etc/sysctl.conf
    fi
else
    echo "El proveedor de congestión TCP ya está en '$desired_cc'."
fi

# Confirmación de finalización
echo -e "\nConfiguración realizada correctamente."
