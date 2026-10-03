$bin = "C:\SimplyGest\ResumenEjecutivo\bin\hmailserver\app\Bin"
Set-Location $bin
$proc = Start-Process -FilePath "$bin\hMailServer.exe" -ArgumentList "/debug" -WorkingDirectory $bin -PassThru
Write-Host "hMailServer started with PID $($proc.Id)"
$proc.WaitForExit()
