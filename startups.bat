@echo off
setlocal

set SCRIPT_PATH=%OneDrive%\repos\command\mouse_jump_svc.ps1
pwsh -Command "Start-Process pwsh -ArgumentList '-File \"%SCRIPT_PATH%\"' -WindowStyle Hidden"

endlocal