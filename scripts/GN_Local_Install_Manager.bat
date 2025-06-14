@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                             GN Local Install Manager
::                           Part of the GN Manager Suite
::
:: Author: GeekNeuron
:: Project: https://github.com/GeekNeuron/GN-Manager
:: =================================================================================

:: --- Common Management Core ---
for /f "tokens=1 delims=#" %%a in ('"prompt #$E# & for %%b in (1) do rem"') do set "ESC=%%a"
set "cReset=!ESC![0m" & set "cError=!ESC![91m" & set "cSuccess=!ESC![92m"
set "cWarning=!ESC![93m" & set "cTitle=!ESC![96m" & set "cChoice=!ESC![93m"

net session >nul 2>nul
if %errorlevel% neq 0 (
    cls & echo !cError! [!] ERROR: Administrator privileges are required.!cReset!
    echo !cWarning! [*] Attempting to re-launch with admin rights...!cReset!
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b
)

set "ConfigFile=GN_Manager_Config.ini"
set "LogFile=GN_Manager_Log.txt"
if not exist "%ConfigFile%" call :CreateDefaultConfig
for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%" ^| findstr /v /b /c:";"') do (
    set "key=%%a" & set "value=%%b" & if /i "!key!"=="LogFile" set "LogFile=!value!"
)
if not exist "%LogFile%" (echo [--- Log file created on %DATE% at %TIME% ---] >> "%LogFile%")
echo [%DATE% %TIME%] [--- GN Local Install Manager Started ---] >> "%LogFile%"
goto Main
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ██╗      ██████╗  ██████╗██╗     ███████╗!cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██║     ██╔═══██╗██╔════╝██║     ██╔════╝!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ██║     ██║   ██║██║     ██║     █████╗  !cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██║     ██║   ██║██║     ██║     ██╔══╝  !cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ███████╗╚██████╔╝╚██████╗███████╗███████╗!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚══════╝ ╚═════╝  ╚═════╝╚══════╝╚══════╝!cReset!
echo !cTitle!                           Local Install Manager                           !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:Main
call :ShowHeader
if "%~1"=="" (
    echo !cWarning! This is a Drag & Drop utility.!cReset!
    echo Please drag a folder containing installers onto this file's icon.
    pause & exit /b
)
set "InputPath=%~1"
if not exist "%InputPath%\" (
    echo !cError![!] ERROR: The provided path is not a folder.!cReset! & pause & exit /b
)
echo [%DATE% %TIME%] Processing local folder: "%InputPath%". >> "%LogFile%"
echo  !cSuccess![+] Processing Folder: %InputPath%!cReset!
echo  !cTitle!------------------------------------------------!cReset!

echo. & echo  !cWarning! --- Installing .EXE files (using /S switch) ---!cReset!
for %%F in ("%InputPath%\*.exe") do (
    echo [*] Installing: "%%~nxF"
    echo [%DATE% %TIME%] Installing local file: "%%~fF". >> "%LogFile%"
    start /wait "" "%%F" /S
    echo    -^> Done.
)

echo. & echo  !cWarning! --- Installing .MSI files (using /qn switch) ---!cReset!
for %%F in ("%InputPath%\*.msi") do (
    echo [*] Installing: "%%~nxF"
    echo [%DATE% %TIME%] Installing local file: "%%~fF". >> "%LogFile%"
    start /wait msiexec.exe /i "%%F" /qn
    echo    -^> Done.
)

echo. & echo  !cTitle!================================================!cReset!
echo  !cSuccess![V] All local installations are complete.!cReset!
echo  !cTitle!================================================!cReset!
echo. & pause & exit /b

:CreateDefaultConfig
(
    echo ; --- GN Manager Suite Configuration ---
    echo ; -- General Settings --
    echo LogFile=GN_Manager_Log.txt
    echo ; -- Cleaner Manager Settings --
    echo QuarantineDir=.\Cleanup_Quarantine
    echo SearchPaths=%%ProgramFiles%% %%ProgramFiles(x86)%% %%APPDATA%% %%LOCALAPPDATA%% %%PROGRAMDATA%%
    echo ; -- Backup Manager Settings --
    echo BackupDir=.\Application_Backups
    echo ; --- Application Data Profiles for Backup Manager ---
    echo ;[Profile:VSCode]
    echo ;Extensions=%%USERPROFILE%%\.vscode\extensions
    echo ;UserSettings=%%USERPROFILE%%\AppData\Roaming\Code\User
) > "%ConfigFile%"
goto :eof
