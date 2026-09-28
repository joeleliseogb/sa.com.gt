param(
    [int]$port = 56990
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "report_engine.ps1")

$global:Sessions = @{}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

try {
    $listener.Start()
    Write-Output "Servidor de Resumen Ejecutivo SimplyGest iniciado en: http://localhost:$port/"
} catch {
    Write-Output "Error al iniciar en puerto $port : $($_.Exception.Message)"
    exit 1
}

$webDir = Join-Path $scriptDir "web"

function Send-Response($context, $content, $contentType, [int]$statusCode = 200, $setCookie = $null) {
    $response = $context.Response
    $response.StatusCode = $statusCode
    $response.ContentType = $contentType
    $response.Headers.Add("Access-Control-Allow-Origin", "*")
    $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS, HEAD")
    $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, Authorization")
    $response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")
    $response.Headers.Add("Pragma", "no-cache")
    $response.Headers.Add("Expires", "0")

    if ($setCookie) {
        $response.Headers.Add("Set-Cookie", $setCookie)
    }

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
    $response.ContentLength64 = $bytes.Length
    if ($context.Request.HttpMethod -ne "HEAD") {
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    $response.OutputStream.Close()
}

function Get-RequestToken($request, $queryParams) {
    $auth = $request.Headers["Authorization"]
    if (-not [string]::IsNullOrEmpty($auth) -and $auth.StartsWith("Bearer ")) {
        return $auth.Substring(7).Trim()
    }
    $cookie = $request.Cookies["sg_session"]
    if ($cookie -and -not [string]::IsNullOrEmpty($cookie.Value)) {
        return $cookie.Value
    }
    if ($queryParams.ContainsKey("token")) {
        return $queryParams["token"]
    }
    return $null
}

function Get-SessionUser($token) {
    if ([string]::IsNullOrEmpty($token)) { return $null }
    if ($global:Sessions.ContainsKey($token)) {
        $sess = $global:Sessions[$token]
        if ($sess.expires -gt [DateTime]::UtcNow) {
            return $sess
        } else {
            $global:Sessions.Remove($token)
        }
    }
    return $null
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $url = $request.Url.LocalPath
        $query = $request.Url.Query

        if ($request.HttpMethod -eq "OPTIONS") {
            Send-Response $context "" "text/plain" 200
            continue
        }

        # Parse query params
        $queryParams = @{}
        if (-not [string]::IsNullOrEmpty($query)) {
            $pairs = ($query.TrimStart('?')).Split('&')
            foreach ($p in $pairs) {
                $kv = $p.Split('=')
                if ($kv.Length -ge 2) {
                    $key = [System.Uri]::UnescapeDataString($kv[0])
                    $val = [System.Uri]::UnescapeDataString($kv[1])
                    $queryParams[$key] = $val
                }
            }
        }

        # Read JSON body if POST
        $postData = @{}
        if ($request.HttpMethod -eq "POST" -and $request.HasEntityBody) {
            $reader = New-Object System.IO.StreamReader($request.InputStream, $request.ContentEncoding)
            $rawBody = $reader.ReadToEnd()
            $reader.Close()
            if (-not [string]::IsNullOrEmpty($rawBody)) {
                try {
                    $postData = $rawBody | ConvertFrom-Json
                } catch {}
            }
        }

        # 1. Frontend Web Files
        if ($url -eq "/" -or $url -eq "/index.html" -or $url -eq "/portal.html" -or $url -eq "/app.html" -or $url -eq "/gestion" -or $url -eq "/gestion.html" -or $url -eq "/tienda" -or $url -eq "/ecommerce.html" -or $url -eq "/correo" -or $url -eq "/correo.html" -or $url -eq "/webmail") {
            $hostHdr = $request.Headers["X-Forwarded-Host"]
            if ([string]::IsNullOrEmpty($hostHdr)) { $hostHdr = $request.Headers["Host"] }
            $subInfo = Resolve-SubdomainCompany $hostHdr
            $cleanHost = if ($hostHdr) { $hostHdr.Split(':')[0].ToLower().Trim() } else { "" }

            # Si el host es correo.sa.com.gt o webmail.sa.com.gt, o si piden /correo o /webmail
            if ($cleanHost -match "^(correo|webmail)\." -or $url -eq "/correo" -or $url -eq "/correo.html" -or $url -eq "/webmail") {
                $targetFile = "correo.html"
            } elseif (-not $subInfo.isDedicated) {
                # Si es el host raíz (sa.com.gt o www.sa.com.gt):
                # Servir el Portal estilo Google (portal.html), o gestion.html si se solicita explícitamente
                if ($url -eq "/gestion" -or $url -eq "/gestion.html" -or $url -eq "/app.html" -or $queryParams.ContainsKey("app") -or $queryParams.ContainsKey("gestion")) {
                    $targetFile = "gestion.html"
                } else {
                    $targetFile = "portal.html"
                }
            } else {
                # Si es un subdominio dedicado (ej. donpollo.sa.com.gt o cdpe.sa.com.gt):
                # Si solicitan /gestion o /admin o /app, entra al Portal de Gestión Empresarial
                if ($url -eq "/gestion" -or $url -eq "/gestion.html" -or $url -eq "/app.html" -or $url -eq "/admin" -or $queryParams.ContainsKey("gestion") -or $queryParams.ContainsKey("app")) {
                    $targetFile = "gestion.html"
                } elseif ($subInfo.slug -eq "cdpe" -or $subInfo.codigo -eq 4) {
                    $targetFile = "cdpe.html"
                } else {
                    $targetFile = "ecommerce.html"
                }
            }

            $filePath = Join-Path $webDir $targetFile
            if (Test-Path $filePath) {
                $html = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
                Send-Response $context $html "text/html; charset=utf-8"
            } else {
                Send-Response $context "Error: No se encontró $targetFile" "text/plain" 404
            }

        # 2. Subdomain Context Resolver
        } elseif ($url -eq "/api/subdomain-context") {
            $hostHdr = $request.Headers["X-Forwarded-Host"]
            if ([string]::IsNullOrEmpty($hostHdr)) { $hostHdr = $request.Headers["Host"] }
            $subInfo = Resolve-SubdomainCompany $hostHdr
            $json = ConvertTo-Json $subInfo -Depth 6
            Send-Response $context $json "application/json; charset=utf-8"

        # 2.05 Global Enterprise & Product Search (Google-Style Multi-Store Search)
        } elseif ($url -eq "/api/buscar") {
            $q = if ($queryParams.ContainsKey("q")) { $queryParams["q"] } else { "" }
            $res = Search-EmpresasYProductos $q
            $json = ConvertTo-Json $res -Depth 8
            Send-Response $context $json "application/json; charset=utf-8"

        # 2.1 Subdomain Directory List (for sa.com.gt Portal)
        } elseif ($url -eq "/api/directorio") {
            $empresas = Get-EmpresasData
            $slugGroups = @{}
            foreach ($emp in $empresas) {
                $slug = ($emp.empresa -replace '[^a-zA-Z0-9]', '').ToLower()
                if ($emp.codigo -eq 0) { $slug = "ejemplo" }
                if (-not $slugGroups.ContainsKey($slug)) {
                    $slugGroups[$slug] = New-Object System.Collections.ArrayList
                }
                [void]$slugGroups[$slug].Add($emp)
            }

            $dirList = @()
            foreach ($slug in $slugGroups.Keys) {
                $group = $slugGroups[$slug]
                $mainEmp = $group | Where-Object { $_.year -eq "2026" -or $_.codigo -eq 1 } | Select-Object -First 1
                if (-not $mainEmp) { $mainEmp = $group[0] }

                $pInfo = Get-EmpresaPeriodos $mainEmp.codigo
                $sector = if ($mainEmp.codigo -eq 1 -or $slug -eq "donpollo") { "Comida Rápida (QSR) - Pollo Frito" } else { "Comercio General / Servicios" }
                $icon = if ($mainEmp.codigo -eq 1 -or $slug -eq "donpollo") { "🍗" } else { "🏢" }

                $allYears = @()
                foreach ($e in $group) {
                    if ($e.year -and ($allYears -notcontains $e.year)) { $allYears += $e.year }
                }
                $yearsDesc = ($allYears | Sort-Object -Descending) -join ", "

                $dirList += [PSCustomObject]@{
                    codigo         = $mainEmp.codigo
                    empresa        = $mainEmp.empresa
                    slug           = $slug
                    subdomain      = "$slug.sa.com.gt"
                    year           = $pInfo.periodoEnCurso
                    periodosTexto  = $yearsDesc
                    periodos       = $pInfo.periodos
                    sector         = $sector
                    icon           = $icon
                    activo         = $mainEmp.activo
                }
            }
            $json = ConvertTo-Json $dirList -Depth 5
            Send-Response $context $json "application/json; charset=utf-8"

        # 3. List Companies
        } elseif ($url -eq "/api/empresas") {
            $empresas = Get-EmpresasData
            $json = ConvertTo-Json $empresas -Depth 5
            Send-Response $context $json "application/json; charset=utf-8"

        # 3.1 List Fiscal Periods for Company
        } elseif ($url -eq "/api/periodos") {
            $emp = if ($queryParams.ContainsKey("empresa")) { $queryParams["empresa"] } else { "1" }
            $pInfo = Get-EmpresaPeriodos $emp
            $json = ConvertTo-Json $pInfo -Depth 5
            Send-Response $context $json "application/json; charset=utf-8"

        # 3.2 List Products / E-Commerce Catalog
        } elseif ($url -eq "/api/catalogo") {
            $emp = if ($queryParams.ContainsKey("empresa")) { $queryParams["empresa"] } else { "1" }
            $catInfo = Get-EmpresaCatalogo $emp
            $json = ConvertTo-Json $catInfo -Depth 6
            Send-Response $context $json "application/json; charset=utf-8"

        # 4. List SimplyGest Users for Company (for login selection)
        } elseif ($url -eq "/api/auth/users") {
            $emp = if ($queryParams.ContainsKey("empresa")) { $queryParams["empresa"] } else { "1" }
            $users = Get-SimplyGestUsers $emp
            $json = ConvertTo-Json $users -Depth 5
            Send-Response $context $json "application/json; charset=utf-8"

        # 5. SimplyGest Authentication Login
        } elseif ($url -eq "/api/auth/login") {
            $emp = if ($postData.empresa) { $postData.empresa } else { "1" }
            $userId = if ($postData.userId) { $postData.userId } else { $postData.username }
            $password = if ($postData.password) { $postData.password } else { "" }

            $valResult = Validate-SimplyGestUser $emp $userId $password
            if ($valResult.success) {
                $token = [Guid]::NewGuid().ToString("N")
                $sessionObj = @{
                    token        = $token
                    codigo       = $valResult.user.codigo
                    nombre       = $valResult.user.nombre
                    usuario      = $valResult.user.usuario
                    tipo         = $valResult.user.tipo
                    estadisticas = $valResult.user.estadisticas
                    resumen      = $valResult.user.resumen
                    empresa      = $valResult.user.empresa
                    created      = [DateTime]::UtcNow
                    expires      = [DateTime]::UtcNow.AddHours(24)
                }
                $global:Sessions[$token] = $sessionObj
                $cookieHdr = "sg_session=$token; Path=/; Max-Age=86400; SameSite=Lax"

                $respObj = @{
                    status = "ok"
                    token  = $token
                    user   = $valResult.user
                }
                $json = ConvertTo-Json $respObj
                Send-Response $context $json "application/json; charset=utf-8" 200 $cookieHdr
            } else {
                $respObj = @{
                    status = "error"
                    error  = $valResult.error
                }
                $json = ConvertTo-Json $respObj
                Send-Response $context $json "application/json; charset=utf-8" 401
            }

        # 6. Current User Session Check
        } elseif ($url -eq "/api/auth/me") {
            $token = Get-RequestToken $request $queryParams
            $user = Get-SessionUser $token
            if ($null -ne $user) {
                $respObj = @{
                    authenticated = $true
                    user = $user
                }
            } else {
                $respObj = @{
                    authenticated = $false
                }
            }
            $json = ConvertTo-Json $respObj
            Send-Response $context $json "application/json; charset=utf-8"

        # 7. Logout
        } elseif ($url -eq "/api/auth/logout") {
            $token = Get-RequestToken $request $queryParams
            if (-not [string]::IsNullOrEmpty($token) -and $global:Sessions.ContainsKey($token)) {
                $global:Sessions.Remove($token)
            }
            $cookieHdr = "sg_session=; Path=/; Max-Age=0; SameSite=Lax"
            $respObj = @{ status = "ok" }
            $json = ConvertTo-Json $respObj
            Send-Response $context $json "application/json; charset=utf-8" 200 $cookieHdr

        # 8. Report API (Protected with SimplyGest Business Rules)
        } elseif ($url -eq "/api/reporte") {
            $token = Get-RequestToken $request $queryParams
            $sessUser = Get-SessionUser $token

            if ($null -eq $sessUser) {
                $errObj = @{ error = "Acceso restringido: Debe iniciar sesión con un usuario activo de SimplyGest." }
                Send-Response $context (ConvertTo-Json $errObj) "application/json; charset=utf-8" 401
                continue
            }

            # Enforce Business Rules
            if ($sessUser.tipo -ne "Administrador" -and -not $sessUser.estadisticas -and -not $sessUser.resumen) {
                $errObj = @{ error = "Regla de Negocio SimplyGest: Su usuario no tiene autorización para consultar Estadísticas o Resumen Ejecutivo." }
                Send-Response $context (ConvertTo-Json $errObj) "application/json; charset=utf-8" 403
                continue
            }

            $emp = if ($queryParams.ContainsKey("empresa")) { $queryParams["empresa"] } else { "$($sessUser.empresa)" }
            $desde = if ($queryParams.ContainsKey("desde")) { $queryParams["desde"] } else { "" }
            $hasta = if ($queryParams.ContainsKey("hasta")) { $queryParams["hasta"] } else { "" }
            $sec = if ($queryParams.ContainsKey("sector")) { $queryParams["sector"] } else { "qsr" }

            $data = Get-ReportData $emp $desde $hasta $sec
            $json = ConvertTo-Json $data -Depth 10
            Send-Response $context $json "application/json; charset=utf-8"

        # 9. Export PDF (Protected with SimplyGest Business Rules)
        } elseif ($url -eq "/api/export-pdf") {
            $token = Get-RequestToken $request $queryParams
            $sessUser = Get-SessionUser $token

            if ($null -eq $sessUser) {
                $errObj = @{ error = "Acceso restringido: Debe iniciar sesión con un usuario activo de SimplyGest." }
                Send-Response $context (ConvertTo-Json $errObj) "application/json; charset=utf-8" 401
                continue
            }

            if ($sessUser.tipo -ne "Administrador" -and -not $sessUser.estadisticas -and -not $sessUser.resumen) {
                $errObj = @{ error = "Regla de Negocio SimplyGest: Su usuario no tiene autorización para exportar este reporte." }
                Send-Response $context (ConvertTo-Json $errObj) "application/json; charset=utf-8" 403
                continue
            }

            $emp = if ($queryParams.ContainsKey("empresa")) { $queryParams["empresa"] } else { "$($sessUser.empresa)" }
            $desde = if ($queryParams.ContainsKey("desde")) { $queryParams["desde"] } else { "" }
            $hasta = if ($queryParams.ContainsKey("hasta")) { $queryParams["hasta"] } else { "" }
            $sec = if ($queryParams.ContainsKey("sector")) { $queryParams["sector"] } else { "qsr" }

            $data = Get-ReportData $emp $desde $hasta $sec
            $cleanName = ($data.empresa.nombre -replace '[^a-zA-Z0-9]', '_').Trim('_')
            if (-not $cleanName) { $cleanName = "Empresa_$emp" }
            $targetPdf = "C:\SimplyGest\Resumen_Ejecutivo_${cleanName}.pdf"

            $ok = Export-ReportPdf $data $targetPdf
            if ($ok) {
                try { Start-Process $targetPdf } catch {}
                $respObj = @{ status = "ok"; path = $targetPdf }
            } else {
                $respObj = @{ status = "error"; error = "No se pudo compilar el PDF con Edge." }
            }

            $json = ConvertTo-Json $respObj
            Send-Response $context $json "application/json; charset=utf-8"

        # 10. Server Info
        } elseif ($url -eq "/api/server-info") {
            $tFile = Join-Path $scriptDir "tunnel_info.json"
            $tUrl = ""
            $ip = "169.58.70.76"
            if (Test-Path $tFile) {
                try {
                    $tObj = Get-Content $tFile -Raw -Encoding UTF8 | ConvertFrom-Json
                    if ($tObj.tunnelUrl) { $tUrl = $tObj.tunnelUrl }
                    if ($tObj.publicIp) { $ip = $tObj.publicIp }
                } catch {}
            }
            $info = @{
                publicIp  = $ip
                directUrl = "http://${ip}/"
                tunnelUrl = $tUrl
            }
            $json = ConvertTo-Json $info
            Send-Response $context $json "application/json; charset=utf-8"

        } else {
            Send-Response $context "Not Found" "text/plain" 404
        }
    } catch {
        Write-Output "Error handling request: $($_.Exception.Message)"
    }
}
