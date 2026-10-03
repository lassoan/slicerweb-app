@echo off
rem Stop the local server of serve-local.bat, also one that has no window to press Ctrl+C in (started
rem in the background): whatever listens on the port.
rem
rem     stop-local.bat [port]       (default: 4176)
setlocal
set "PORT=%~1"
if "%PORT%"=="" set "PORT=4176"
powershell -NoProfile -Command "$c = Get-NetTCPConnection -LocalPort %PORT% -State Listen -ErrorAction SilentlyContinue; if (-not $c) { Write-Host 'Nothing is serving on port %PORT%'; exit 0 }; foreach ($x in $c) { $p = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $x.OwningProcess); Write-Host ('Stopping ' + $p.Name + ' (process ' + $x.OwningProcess + ') on port %PORT%'); Stop-Process -Id $x.OwningProcess -Force }"
