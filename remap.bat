@echo off
setlocal

rem Prepare ... Set IME Config: VK240(Eisu) = IME OFF, IME ON/OFF, IME ON/OFF, ...

set SRC_BASE=%~dp0\powertoysconfig
set TARGET_JSON=%LOCALAPPDATA%\Microsoft\PowerToys\Keyboard Manager\default.json

set IS_VALID=FALSE
if "%~1"=="jp" set IS_VALID=TRUE
if "%~1"=="us" set IS_VALID=TRUE

if %IS_VALID%==TRUE (
    copy /Y "%SRC_BASE%\%~1.json" "%TARGET_JSON%"
) else (
    echo Invalid argument. Please specify "jp" or "us".
    pause
    exit /B 1
)

rem workaround to apply
timeout 2

taskkill /IM PowerToys.exe /F /T
start "" %LOCALAPPDATA%\PowerToys\PowerToys.exe

endlocal
exit /B 0
