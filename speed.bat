@echo off

rem Obtener la información de configuración de red actual
ipconfig /all

rem Comprobar si el adaptador de red es compatible con TCP Chimney Offload
if "%adapter_type%" == "802.11" (
    echo "El adaptador de red no es compatible con TCP Chimney Offload"
    exit /b
)

rem Habilitar TCP Chimney Offload
netsh int tcp set global chimney=enabled

rem Comprobar si hay problemas con firewalls o VPN
if %errorlevel% == 1 (
    echo "Se han detectado problemas con firewalls o VPN"
    exit /b
)

rem Establecer el nivel de ajuste automático de TCP en "normal"
netsh int tcp set global autotuninglevel=normal

rem Comprobar si hay problemas de rendimiento
ping 8.8.8.8 -n 10
if %errorlevel% == 1 (
    echo "El nivel de ajuste automático de TCP no es compatible con tu red"
    exit /b
)

rem Establecer el proveedor de congestión TCP en CTCP
netsh int tcp set global congestionprovider=ctcp

rem Comprobar si hay problemas de compatibilidad
if %errorlevel% == 1 (
    echo "El proveedor de congestión TCP CTCP no es compatible con tu red"
    exit /b
)

echo "Se han realizado los cambios con éxito"

rem Agregar arte ASCII con el texto "Speeder"
echo.
echo.
echo.
echo.   _________                        .___            
echo.  /   _____/_____   ____   ____   __| _/___________ 
echo.  \_____  \\____ \_/ __ \_/ __ \ / __ |/ __ \_  __ \
echo.  /        \  |_> >  ___/\  ___// /_/ \  ___/|  | \/
echo. /_______  /   __/ \___  >\___  >____ |\___  >__|   
echo.         \/|__|        \/     \/     \/    \/
echo.
echo.                 by Quamagi & Bard
echo.
