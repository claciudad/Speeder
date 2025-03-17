# Solicitar elevación de privilegios si no se ejecuta como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process -FilePath "PowerShell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Mostrar la configuración de red actual
Write-Host "Obteniendo información de configuración de red actual..." -ForegroundColor Cyan
Get-NetIPConfiguration | Format-List

# Obtener el adaptador de red activo
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1

if (-not $adapter) {
    Write-Host "No se encontró un adaptador de red activo." -ForegroundColor Red
    exit
}

Write-Host "Adaptador activo: $($adapter.Name) - $($adapter.InterfaceDescription)" -ForegroundColor Green

# Verificar si el adaptador es inalámbrico
if ($adapter.InterfaceDescription -match "802.11") {
    Write-Host "El adaptador de red es inalámbrico y no es compatible con optimizaciones avanzadas de TCP." -ForegroundColor Yellow
    exit
}

# Función para verificar y establecer configuraciones de red
function Set-NetTcpGlobalSetting {
    param (
        [string]$SettingName,
        [string]$ExpectedValue,
        [string]$Command
    )
    
    $currentValue = netsh int tcp show global | Select-String $SettingName | ForEach-Object { $_.ToString().Split(':')[-1].Trim() }
    
    if ($currentValue -ne $ExpectedValue) {
        Write-Host "Configurando $SettingName en '$ExpectedValue'..." -ForegroundColor Cyan
        Invoke-Expression $Command
    } else {
        Write-Host "$SettingName ya está configurado en '$ExpectedValue'." -ForegroundColor Green
    }
}

# Aplicar configuraciones de TCP
Set-NetTcpGlobalSetting "Receive Window Auto-Tuning Level" "normal" "netsh int tcp set global autotuninglevel=normal"

# Configurar proveedor de congestión TCP correctamente
$tcpCongestionProviders = netsh int tcp show supplemental | Select-String "CTCP"
if (-not $tcpCongestionProviders) {
    Write-Host "Configurando CTCP como proveedor de control de congestión TCP..." -ForegroundColor Cyan
    netsh int tcp set supplemental template=internet congestionprovider=ctcp
} else {
    Write-Host "El proveedor de congestión TCP ya está configurado en 'CTCP'." -ForegroundColor Green
}

# Confirmación de finalización
Write-Host "`nConfiguración de red optimizada correctamente." -ForegroundColor Green
