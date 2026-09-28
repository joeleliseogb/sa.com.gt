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
    Write-Host "[1/3] Iniciando motor analitico SimplyGest (ODBC x86)..." -ForegroundColor Yellow
    $psx86 = "$env:SystemRoot\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"
    $serverScript = Join-Path $scriptDir "server.ps1"
    Start-Process -FilePath $psx86 -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$serverScript`"" -WindowStyle Hidden
    Start-Sleep -Seconds 2
} else {
    Write-Host "[1/3] Motor analitico SimplyGest activo en puerto 56990." -ForegroundColor Green
}

# 2. Iniciar Servidor Web Caddy (Puerto 80)
$isCaddyRunning = $false
try {
    $conn80 = Get-NetTCPConnection -LocalPort 80 -ErrorAction SilentlyContinue
    if ($conn80) { $isCaddyRunning = $true }
} catch {}

$caddyExe = Join-Path $scriptDir "bin\caddy.exe"
$caddyFile = Join-Path $scriptDir "Caddyfile"

if (-not $isCaddyRunning -and (Test-Path $caddyExe)) {
    Write-Host "[2/3] Iniciando Servidor Web Caddy en puerto 80..." -ForegroundColor Yellow
    Start-Process -FilePath $caddyExe -ArgumentList "run --config `"$caddyFile`"" -WorkingDirectory $scriptDir -WindowStyle Hidden
    Start-Sleep -Seconds 2
} else {
    Write-Host "[2/3] Servidor Web Caddy activo en puerto 80." -ForegroundColor Green
}

# 3. Iniciar Tunel Seguro Cloudflare (HTTPS para móviles)
$cfExe = Join-Path $scriptDir "bin\cloudflared.exe"
$cfLog = Join-Path $scriptDir "tunnel.log"
$cfRunning = Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue

if (-not $cfRunning -and (Test-Path $cfExe)) {
    Write-Host "[3/3] Estableciendo tunel seguro HTTPS para moviles..." -ForegroundColor Yellow
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
        Write-Host "[3/3] Tunel HTTPS activo: $foundUrl" -ForegroundColor Green
    } else {
        Write-Host "[3/3] Tunel iniciado. Registrando enlace..." -ForegroundColor Yellow
    }
} else {
    Write-Host "[3/3] Tunel seguro Cloudflare ya esta activo." -ForegroundColor Green
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
