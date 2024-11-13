@echo off
setlocal

set SCRIPT_PATH=%~dp0\mouse_jump_svc.ps1
pwsh -Command "Start-Process pwsh -ArgumentList '-File \"%SCRIPT_PATH%\"' -WindowStyle Hidden"

rem Prepare: git clone https://github.com/fruitjuice088/battstray.git
start "" "%~dp0\..\battstray\battstray.pyw"

endlocal