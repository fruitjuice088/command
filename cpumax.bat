@echo off
setlocal

set SCRIPT_PREFIX=pwsh -WindowStyle Hidden -File "%~dp0\cpumax.ps1"
if "%~1"=="" (
    %SCRIPT_PREFIX%
) else (
    %SCRIPT_PREFIX% %1
)

endlocal
