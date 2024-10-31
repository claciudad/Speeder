@echo off

rem Solicitar elevación de privilegios
runas.exe /user:%USERNAME% "%~dp0%~n0"

rem Mostrar configuración de red actual
ipconfig /all

rem Comprobar y habilitar TCP Chimney Offload si no está habilitado
netsh int tcp show global | find "Chimney" | find "enabled" >nul
if %errorlevel% neq 0 (
    echo Habilitando TCP Chimney Offload...
    netsh int tcp set global chimney=enabled
) else (
    echo TCP Chimney Offload ya está habilitado
)

rem Comprobar y establecer el nivel de ajuste automático de TCP en "normal" si no lo está
netsh int tcp show global | find "Receive-Side Scaling" | find "normal" >nul
if %errorlevel% neq 0 (
    echo Estableciendo ajuste automático de TCP en 'normal'...
    netsh int tcp set global autotuninglevel=normal
) else (
    echo Nivel de ajuste automático de TCP ya configurado en 'normal'
)

rem Comprobar y configurar el proveedor de congestión TCP en CTCP si no está configurado
netsh int tcp show global | find "Congestion" | find "ctcp" >nul
if %errorlevel% neq 0 (
    echo Estableciendo proveedor de congestión TCP en 'CTCP'...
    netsh int tcp set global congestionprovider=ctcp
) else (
    echo Proveedor de congestión TCP ya configurado en 'CTCP'
)

rem Confirmación de finalización
echo.
echo Configuración completada exitosamente
echo.

rem Arte ASCII con el texto "Speeder"
echo   _________                        .___            
echo  /   _____/_____   ____   ____   __| _/___________ 
echo  \_____  \\____ \_/ __ \_/ __ \ / __ |/ __ \_  __ \
echo  /        \  |_> >  ___/\  ___// /_/ \  ___/|  | \/
echo /_______  /   __/ \___  >\___  >____ |\___  >__|   
echo         \/|__|        \/     \/     \/    \/
echo.
echo                by Quamagi & Bard
echo.

:end
