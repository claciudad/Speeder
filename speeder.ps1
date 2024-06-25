# Solicitar elevación para hacer los cambios
Start-Process PowerShell -Verb RunAs

# Obtener la información de configuración de red actual
Write-Host "Información de configuración de red actual:"
ipconfig /all

# Obtener el tipo de adaptador de red
$adapterType = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true} | Select-Object -ExpandProperty Description

# Comprobar si el adaptador de red es compatible con TCP Chimney Offload
if ($adapterType -like "*802.11*") {
    Write-Host "El adaptador de red no es compatible con TCP Chimney Offload"
    exit
}

# Comprobar si TCP Chimney Offload ya está habilitado
$chimney = netsh int tcp show global | Select-String "Chimney"
if ($chimney -match "enabled") {
    Write-Host "TCP Chimney Offload ya está habilitado."
} else {
    # Habilitar TCP Chimney Offload
    netsh int tcp set global chimney=enabled
    Write-Host "TCP Chimney Offload ha sido habilitado."
}

# Comprobar si el nivel de ajuste automático de TCP ya está en "normal"
$autoTuning = netsh int tcp show global | Select-String "Receive-Side Scaling"
if ($autoTuning -match "normal") {
    Write-Host "El nivel de ajuste automático de TCP ya está en 'normal'."
} else {
    # Establecer el nivel de ajuste automático de TCP en "normal"
    netsh int tcp set global autotuninglevel=normal
    Write-Host "El nivel de ajuste automático de TCP ha sido establecido en 'normal'."
}

# Comprobar si el proveedor de congestión TCP ya está en CTCP
$ctcp = netsh int tcp show global | Select-String "Congestion"
if ($ctcp -match "ctcp") {
    Write-Host "El proveedor de congestión TCP ya está en CTCP."
} else {
    # Establecer el proveedor de congestión TCP en CTCP
    netsh int tcp set global congestionprovider=ctcp
    Write-Host "El proveedor de congestión TCP ha sido establecido en CTCP."
}

Write-Host "Configuración realizada correctamente"
