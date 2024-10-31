# Solicitar elevación de privilegios si no se ejecuta como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "PowerShell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Mostrar la configuración de red actual
Write-Host "Obteniendo información de configuración de red actual..."
ipconfig /all

# Obtener el adaptador de red activo (IPEnabled = True)
$adapter = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true} | Select-Object -First 1

# Verificar si el adaptador es compatible con TCP Chimney Offload
if ($adapter.Description -match "802.11") {
    Write-Host "El adaptador de red es inalámbrico y no es compatible con TCP Chimney Offload."
    exit
}

# Verificar y habilitar TCP Chimney Offload si es necesario
$chimneyStatus = netsh int tcp show global | Select-String "Chimney" | ForEach-Object { $_.ToString().Split(':')[-1].Trim() }
if ($chimneyStatus -ne "enabled") {
    Write-Host "Habilitando TCP Chimney Offload..."
    netsh int tcp set global chimney=enabled
} else {
    Write-Host "TCP Chimney Offload ya está habilitado."
}

# Verificar y establecer ajuste automático de TCP en 'normal' si es necesario
$autoTuningStatus = netsh int tcp show global | Select-String "Receive Window Auto-Tuning Level" | ForEach-Object { $_.ToString().Split(':')[-1].Trim() }
if ($autoTuningStatus -ne "normal") {
    Write-Host "Estableciendo nivel de ajuste automático de TCP en 'normal'..."
    netsh int tcp set global autotuninglevel=normal
} else {
    Write-Host "El nivel de ajuste automático de TCP ya está en 'normal'."
}

# Verificar y configurar el proveedor de congestión TCP en CTCP si es necesario
$congestionProviderStatus = netsh int tcp show global | Select-String "Add-On Congestion Control Provider" | ForEach-Object { $_.ToString().Split(':')[-1].Trim() }
if ($congestionProviderStatus -ne "ctcp") {
    Write-Host "Estableciendo proveedor de congestión TCP en 'CTCP'..."
    netsh int tcp set global congestionprovider=ctcp
} else {
    Write-Host "El proveedor de congestión TCP ya está en 'CTCP'."
}

# Confirmación de finalización
Write-Host "`nConfiguración realizada correctamente."
