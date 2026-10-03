# SimplyGest - Resumen Ejecutivo Service Manager
$ErrorActionPreference = "Continue"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $scriptDir) { $scriptDir = "C:\SimplyGest\ResumenEjecutivo" }

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  Iniciando Servicios de Resumen Ejecutivo SimplyGest" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# 1. Iniciar Backend SysWOW64 (Puerto 56990)
$isBackendRunning = $false
try {
    $conn = Get-NetTCPConnection -LocalPort 56990 -ErrorAction SilentlyContinue
    if ($conn) { $isBackendRunning = $true }
} catch {}

if (-not $isBackendRunning) {
    Write-Host "[1/6] Iniciando motor analitico SimplyGest (ODBC x86)..." -ForegroundColor Yellow
    $psx86 = "$env:SystemRoot\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
    $serverScript = Join-Path $scriptDir "server.ps1"
    Start-Process -FilePath $psx86 -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$serverScript`"" -WindowStyle Hidden
    Start-Sleep -Seconds 2
} else {
    Write-Host "[1/6] Motor analitico SimplyGest activo en puerto 56990." -ForegroundColor Green
}

# 2. Iniciar MariaDB Enterprise Engine (Puerto 3306)
$isMariaRunning = $false
try {
    $conn3306 = Get-NetTCPConnection -LocalPort 3306 -ErrorAction SilentlyContinue
    if ($conn3306) { $isMariaRunning = $true }
} catch {}

$mysqldExe = Join-Path $scriptDir "bin\mariadb\bin\mysqld.exe"
$myIni = Join-Path $scriptDir "bin\mariadb\my.ini"
if (-not $isMariaRunning -and (Test-Path $mysqldExe)) {
    Write-Host "[2/6] Iniciando MariaDB Enterprise en puerto 3306..." -ForegroundColor Yellow
    Start-Process -FilePath $mysqldExe -ArgumentList "--defaults-file=`"$myIni`" --console" -WorkingDirectory (Join-Path $scriptDir "bin\mariadb") -WindowStyle Hidden
    Start-Sleep -Seconds 2
} else {
    Write-Host "[2/6] Base de datos MariaDB activa en puerto 3306." -ForegroundColor Green
}

# 3. Iniciar Servidor de Correo hMailServer (Puertos 25, 110, 143, 587)
$isHmailRunning = $false
try {
    $conn143 = Get-NetTCPConnection -LocalPort 143 -ErrorAction SilentlyContinue
    if ($conn143) { $isHmailRunning = $true }
} catch {}

$hmailExe = Join-Path $scriptDir "bin\hmailserver\app\Bin\hMailServer.exe"
if (-not $isHmailRunning -and (Test-Path $hmailExe)) {
    Write-Host "[3/6] Iniciando servidor de correo hMailServer..." -ForegroundColor Yellow
    Start-Process -FilePath $hmailExe -ArgumentList "/debug" -WorkingDirectory (Split-Path $hmailExe) -WindowStyle Hidden
    Start-Sleep -Seconds 2
} else {
    Write-Host "[3/6] Servidor de correo hMailServer activo (IMAP/SMTP/POP3)." -ForegroundColor Green
}

# 4. Iniciar Webmail Roundcube (PHP 8.2 en Puerto 8080)
$isRcRunning = $false
try {
    $conn8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
    if ($conn8080) { $isRcRunning = $true }
} catch {}

$phpExe = Join-Path $scriptDir "bin\php\php.exe"
$rcRoot = Join-Path $scriptDir "web\roundcube"
if (-not $isRcRunning -and (Test-Path $phpExe)) {
    Write-Host "[4/6] Iniciando Roundcube Webmail en puerto 8080..." -ForegroundColor Yellow
    Start-Process -FilePath $phpExe -ArgumentList "-S 127.0.0.1:8080 -t `"$rcRoot`"" -WorkingDirectory $rcRoot -WindowStyle Hidden
    Start-Sleep -Seconds 1
} else {
    Write-Host "[4/6] Roundcube Webmail activo en puerto 8080." -ForegroundColor Green
}

# 5. Iniciar Manager.io Server Edition (Puerto 5000)
$isManagerRunning = $false
try {
    $conn5000 = Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue
    if ($conn5000) { $isManagerRunning = $true }
} catch {}

$managerExe = "C:\Manager IO\ManagerServer.exe"
if (-not $isManagerRunning -and (Test-Path $managerExe)) {
    Write-Host "[5/7] Iniciando Manager.io Server en puerto 5000..." -ForegroundColor Yellow
    Start-Process -FilePath $managerExe -ArgumentList "-port 5000" -WorkingDirectory "C:\Manager IO" -WindowStyle Hidden
    Start-Sleep -Seconds 2
} else {
    Write-Host "[5/7] Manager.io Server activo en puerto 5000." -ForegroundColor Green
}

# 6. Iniciar Servidor Web Caddy (Puerto 80 y 443)
$isCaddyRunning = $false
try {
    $conn80 = Get-NetTCPConnection -LocalPort 80 -ErrorAction SilentlyContinue
    if ($conn80) { $isCaddyRunning = $true }
} catch {}

$caddyExe = Join-Path $scriptDir "bin\caddy.exe"
$caddyFile = Join-Path $scriptDir "Caddyfile"

if (-not $isCaddyRunning -and (Test-Path $caddyExe)) {
    Write-Host "[6/7] Iniciando Servidor Web Caddy en puertos 80 y 443..." -ForegroundColor Yellow
    Start-Process -FilePath $caddyExe -ArgumentList "run --config `"$caddyFile`"" -WorkingDirectory $scriptDir -WindowStyle Hidden
    Start-Sleep -Seconds 2
} else {
    Write-Host "[6/7] Servidor Web Caddy activo en puertos 80 y 443." -ForegroundColor Green
}

# 7. Iniciar Tunel Seguro Cloudflare (HTTPS para móviles)
$cfExe = Join-Path $scriptDir "bin\cloudflared.exe"
$cfLog = Join-Path $scriptDir "tunnel.log"
$cfRunning = Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue

if (-not $cfRunning -and (Test-Path $cfExe)) {
    Write-Host "[7/7] Estableciendo tunel seguro HTTPS para moviles..." -ForegroundColor Yellow
    Start-Process -FilePath $cfExe -ArgumentList "tunnel --url http://127.0.0.1:80 --logfile `"$cfLog`"" -WorkingDirectory $scriptDir -WindowStyle Hidden
    
    # Esperar URL asignada
    $foundUrl = ""
    for ($i = 0; $i -lt 15; $i++) {
        Start-Sleep -Seconds 1
        if (Test-Path $cfLog) {
            $content = Get-Content $cfLog -Raw -ErrorAction SilentlyContinue
            if ($content -match "https://[a-zA-Z0-9-]+\.trycloudflare\.com") {
                $foundUrl = $matches[0]
                break
            }
        }
    }

    if ($foundUrl) {
        $info = @{
            tunnelUrl = $foundUrl
            publicIp  = "169.58.70.76"
            directUrl = "http://169.58.70.76/"
        }
        $info | ConvertTo-Json | Set-Content (Join-Path $scriptDir "tunnel_info.json") -Encoding UTF8
        Write-Host "[7/7] Tunel HTTPS activo: $foundUrl" -ForegroundColor Green
    } else {
        Write-Host "[7/7] Tunel iniciado. Registrando enlace..." -ForegroundColor Yellow
    }
} else {
    Write-Host "[7/7] Tunel seguro Cloudflare ya esta activo." -ForegroundColor Green
}

# 8. Iniciar Servicio de Copias de Seguridad GTcop (Puerto 56992)
$isGtcopBackupRunning = $false
try {
    $conn56992 = Get-NetTCPConnection -LocalPort 56992 -ErrorAction SilentlyContinue
    if ($conn56992) { $isGtcopBackupRunning = $true }
} catch {}

$gtcopBackupScript = Join-Path $scriptDir "bin\gtcop_backup_service.ps1"
if (-not $isGtcopBackupRunning -and (Test-Path $gtcopBackupScript)) {
    Write-Host "[8/9] Iniciando Servicio de Copias de Seguridad GTcop en puerto 56992..." -ForegroundColor Yellow
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$gtcopBackupScript`"" -WorkingDirectory (Split-Path $gtcopBackupScript) -WindowStyle Hidden
    Start-Sleep -Seconds 1
} else {
    Write-Host "[8/9] Servicio de Copias de Seguridad GTcop activo en puerto 56992." -ForegroundColor Green
}

# 9. Iniciar Proxy Filtrado GTcop - Accion Cooperativa (Puerto 8082)
$isGtcopProxyRunning = $false
try {
    $conn8082 = Get-NetTCPConnection -LocalPort 8082 -ErrorAction SilentlyContinue
    if ($conn8082) { $isGtcopProxyRunning = $true }
} catch {}

$gtcopProxyExe = Join-Path $scriptDir "bin\gtcop_proxy.exe"
if (-not $isGtcopProxyRunning -and (Test-Path $gtcopProxyExe)) {
    Write-Host "[9/9] Iniciando Proxy Filtrado GTcop (Accion Cooperativa) en puerto 8082..." -ForegroundColor Yellow
    Start-Process -FilePath $gtcopProxyExe -WorkingDirectory (Split-Path $gtcopProxyExe) -WindowStyle Hidden
    Start-Sleep -Seconds 1
} else {
    Write-Host "[9/9] Proxy Filtrado GTcop (Accion Cooperativa) activo en puerto 8082." -ForegroundColor Green
}

Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "  ENLACES DE ACCESO DISPONIBLES:" -ForegroundColor White
Write-Host "  - En tu PC:          http://localhost/" -ForegroundColor Gray
Write-Host "  - Enlace Directo IP: http://169.58.70.76/" -ForegroundColor Yellow
$tInfoFile = Join-Path $scriptDir "tunnel_info.json"
if (Test-Path $tInfoFile) {
    try {
        $ti = Get-Content $tInfoFile -Raw | ConvertFrom-Json
        if ($ti.tunnelUrl) {
            Write-Host "  - Movil (HTTPS):     $($ti.tunnelUrl)" -ForegroundColor Green
        }
    } catch {}
}
Write-Host "===================================================" -ForegroundColor Cyan
