rem Solicitar elevación para hacer los cambios
runas.exe /user:%USERNAME% "%~dp0%~n0"

@echo off

rem Obtener la información de configuración de red actual
ipconfig /all

rem Comprobar si el adaptador de red es compatible con TCP Chimney Offload
if "%adapter_type%" == "802.11" (
  echo "El adaptador de red no es compatible con TCP Chimney Offload"
  goto end
)

rem Comprobar si TCP Chimney Offload ya está habilitado
netsh int tcp show global | find "Chimney" | find "enabled" >nul
if %errorlevel% == 0 goto chimney_enabled

rem Habilitar TCP Chimney Offload
netsh int tcp set global chimney=enabled

:chimney_enabled

rem Comprobar si el nivel de ajuste automático de TCP ya está en "normal" 
netsh int tcp show global | find "Receive-Side Scaling" | find "normal" >nul
if %errorlevel% == 0 goto autotuning_set

rem Establecer el nivel de ajuste automático de TCP en "normal"
netsh int tcp set global autotuninglevel=normal

:autotuning_set

rem Comprobar si el proveedor de congestión TCP ya está en CTCP
netsh int tcp show global | find "Congestion" | find "ctcp" >nul
if %errorlevel% == 0 goto ctcp_set 

rem Establecer el proveedor de congestión TCP en CTCP
netsh int tcp set global congestionprovider=ctcp

:ctcp_set

echo "Configuración realizada correctamente"

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

:end
