Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File ""C:\SimplyGest\ResumenEjecutivo\service_manager.ps1""", 0, False
