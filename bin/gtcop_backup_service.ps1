param(
    [int]$port = 56992
)

$bin = "C:\inetpub\wwwroot\gtcop\bin"
[AppDomain]::CurrentDomain.add_AssemblyResolve({ param($s, $e) 
    if ($e.Name -match "MySql.Data") { return [System.Reflection.Assembly]::LoadFrom("$bin\MySql.Data.dll") }
    if ($e.Name -match "MySqlBackup") { return [System.Reflection.Assembly]::LoadFrom("$bin\MySqlBackup.dll") }
})
Add-Type -Path "$bin\MySql.Data.dll"
Add-Type -Path "$bin\MySqlBackup.dll"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Fix MariaDB 10.6 utf8mb3 mapping in MySql.Data
$t = [MySql.Data.MySqlClient.MySqlConnection].Assembly.GetType("MySql.Data.MySqlClient.CharSetMap")
$mapField = $t.GetField("_mapping", [System.Reflection.BindingFlags]"NonPublic,Static")
$map = $mapField.GetValue($null)
if ($map.ContainsKey("utf8") -and -not $map.ContainsKey("utf8mb3")) {
    $map["utf8mb3"] = $map["utf8"]
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$port/")

try {
    $listener.Start()
    Write-Output "GTcop Backup Service started on http://127.0.0.1:$port/"
} catch {
    Write-Output "Error starting listener on port ${port}: $($_.Exception.Message)"
    exit 1
}

function Generate-BackupZip() {
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection("Server=127.0.0.1; Port=3306; Database=gtcop; Uid=gtcopa; Pwd=Joel@59124393; CharacterSet=utf8mb4;")
    $cmd = $conn.CreateCommand()
    $backup = New-Object MySql.Data.MySqlClient.MySqlBackup($cmd)
    $conn.Open()
    
    $sw = New-Object System.IO.StringWriter
    try {
        $backup.ExportToTextWriter($sw)
    } finally {
        $conn.Close()
    }
    
    $sqlBytes = [System.Text.Encoding]::UTF8.GetBytes($sw.ToString())
    
    $zipMs = New-Object System.IO.MemoryStream
    $archive = New-Object System.IO.Compression.ZipArchive($zipMs, [System.IO.Compression.ZipArchiveMode]::Create, $true)
    $entry = $archive.CreateEntry("Backup.sql", [System.IO.Compression.CompressionLevel]::Optimal)
    $entryStream = $entry.Open()
    $entryStream.Write($sqlBytes, 0, $sqlBytes.Length)
    $entryStream.Close()
    $archive.Dispose()
    
    return $zipMs.ToArray()
}

function Restore-BackupZip([byte[]]$zipData) {
    $zipMs = New-Object System.IO.MemoryStream($zipData, $false)
    $archive = New-Object System.IO.Compression.ZipArchive($zipMs, [System.IO.Compression.ZipArchiveMode]::Read)
    $sqlEntry = $archive.Entries | Where-Object { $_.Name -like "*.sql" } | Select-Object -First 1
    if (-not $sqlEntry) {
        throw "El archivo ZIP no contiene ningun archivo .sql valido."
    }
    
    $reader = New-Object System.IO.StreamReader($sqlEntry.Open(), [System.Text.Encoding]::UTF8)
    $conn = New-Object MySql.Data.MySqlClient.MySqlConnection("Server=127.0.0.1; Port=3306; Database=gtcop; Uid=gtcopa; Pwd=Joel@59124393; CharacterSet=utf8mb4;")
    $cmd = $conn.CreateCommand()
    $backup = New-Object MySql.Data.MySqlClient.MySqlBackup($cmd)
    $conn.Open()
    try {
        $backup.ImportFromTextReader($reader)
    } finally {
        $reader.Close()
        $conn.Close()
        $archive.Dispose()
    }
}

function Extract-MultipartBoundary($contentType) {
    if ($contentType -match 'boundary=(?:"([^"]+)"|([^;]+))') {
        return $(if ($matches[1]) { $matches[1] } else { $matches[2] }).Trim()
    }
    return $null
}

function Extract-FileFromMultipart([byte[]]$bodyBytes, [string]$boundary) {
    $enc = [System.Text.Encoding]::GetEncoding("ISO-8859-1")
    $str = $enc.GetString($bodyBytes)
    $delim = "--$boundary"
    $parts = $str.Split(@($delim), [StringSplitOptions]::RemoveEmptyEntries)
    foreach ($part in $parts) {
        if ($part.Contains('name="file"')) {
            $headerEnd = $part.IndexOf("`r`n`r`n")
            if ($headerEnd -ge 0) {
                $content = $part.Substring($headerEnd + 4)
                if ($content.EndsWith("`r`n")) {
                    $content = $content.Substring(0, $content.Length - 2)
                }
                return $enc.GetBytes($content)
            }
        }
    }
    return $null
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $req = $context.Request
        $res = $context.Response
        
        $path = $req.Url.AbsolutePath
        $method = $req.HttpMethod
        
        # Check authentication cookie (.ASPXAUTH)
        $authCookie = $req.Cookies[".ASPXAUTH"]
        if (-not $authCookie -or [string]::IsNullOrEmpty($authCookie.Value)) {
            # Redirect to login if not authenticated
            $res.StatusCode = 302
            $res.RedirectLocation = "/Account/Login?ReturnUrl=%2fBackup"
            $res.Close()
            continue
        }
        
        if ($path -eq "/Backup/Backup" -and ($method -eq "GET" -or $method -eq "HEAD")) {
            try {
                $zipBytes = Generate-BackupZip
                $fileName = "backup-" + (Get-Date).ToString("dd-MM-yyyy_HHmmss") + ".zip"
                
                $res.StatusCode = 200
                $res.ContentType = "application/zip"
                $res.Headers.Add("Content-Disposition", "attachment; filename=$fileName")
                $res.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate")
                $res.ContentLength64 = $zipBytes.Length
                if ($method -eq "GET") {
                    $res.OutputStream.Write($zipBytes, 0, $zipBytes.Length)
                }
                $res.OutputStream.Close()
            } catch {
                $errMsg = $_.Exception.Message.Replace("'", "\'")
                $errHtml = "<html><head><meta charset='utf-8'></head><body><script>alert('Error al generar la copia de seguridad: $errMsg'); window.location.href='/Backup';</script></body></html>"
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($errHtml)
                $res.StatusCode = 200
                $res.ContentType = "text/html; charset=utf-8"
                $res.ContentLength64 = $bytes.Length
                $res.OutputStream.Write($bytes, 0, $bytes.Length)
                $res.OutputStream.Close()
            }
        }
        elseif ($path -eq "/Backup/Restore" -and $method -eq "POST") {
            try {
                $boundary = Extract-MultipartBoundary $req.ContentType
                if (-not $boundary) {
                    throw "Formato de archivo no valido (boundary no encontrado)."
                }
                
                $ms = New-Object System.IO.MemoryStream
                $req.InputStream.CopyTo($ms)
                $bodyBytes = $ms.ToArray()
                $fileBytes = Extract-FileFromMultipart $bodyBytes $boundary
                
                if (-not $fileBytes -or $fileBytes.Length -eq 0) {
                    throw "No se recibio ningun archivo o el archivo esta vacio."
                }
                
                Restore-BackupZip $fileBytes
                
                $successHtml = "<html><head><meta charset='utf-8'></head><body><script>alert('Restauracion Completada Exitosamente'); window.location.href='/Backup';</script></body></html>"
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($successHtml)
                $res.StatusCode = 200
                $res.ContentType = "text/html; charset=utf-8"
                $res.ContentLength64 = $bytes.Length
                $res.OutputStream.Write($bytes, 0, $bytes.Length)
                $res.OutputStream.Close()
            } catch {
                $errMsg = $_.Exception.Message.Replace("'", "\'")
                $errHtml = "<html><head><meta charset='utf-8'></head><body><script>alert('Error durante la restauracion: $errMsg'); window.location.href='/Backup';</script></body></html>"
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($errHtml)
                $res.StatusCode = 200
                $res.ContentType = "text/html; charset=utf-8"
                $res.ContentLength64 = $bytes.Length
                $res.OutputStream.Write($bytes, 0, $bytes.Length)
                $res.OutputStream.Close()
            }
        }
        else {
            $res.StatusCode = 404
            $res.Close()
        }
    } catch {
        # Listener loop error handling
    }
}
