@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                         GN Restore Point Manager
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
if not exist "%ConfigFile%" (cls & echo !cError!Config file not found. Please run a main tool first.!cReset! & pause & exit /b)
set "LogFile=GN_Manager_Log.txt"
for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%" ^| findstr /v /b /c:";"') do (
    set "key=%%a" & set "value=%%b" & if /i "!key!"=="LogFile" set "LogFile=!value!"
)
if not exist "%LogFile%" (echo [--- Log file created on %DATE% at %TIME% ---] >> "%LogFile%")
echo [%DATE% %TIME%] [--- GN Restore Point Manager Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ██████╗ ███████╗███████╗████████╗ ██████╗ !cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔═══██╗!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ██████╔╝█████╗  ███████╗   ██║   ██║   ██║!cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██╔══██╗██╔══╝  ╚════██║   ██║   ██║   ██║!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ██║  ██║███████╗███████║   ██║   ╚██████╔╝!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝    ╚═════╝ !cReset!
echo !cTitle!                         Restore Point Manager                            !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo                   !cTitle!Windows System Restore Management!cReset!
echo.
echo    [1] List All Restore Points
echo    [2] Create a New Restore Point
echo    [3] !cError!Delete a Restore Point (Advanced)!cReset!
echo.
echo    [4] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-4): !cReset!"
if "%choice%"=="1" goto ListPoints
if "%choice%"=="2" goto CreatePoint
if "%choice%"=="3" goto DeletePoint
if "%choice%"=="4" exit /b
goto MainMenu

:ListPoints
call :ShowHeader & echo  --- Available System Restore Points --- & echo.
powershell -Command "Get-ComputerRestorePoint"
echo. & pause & goto MainMenu

:CreatePoint
call :ShowHeader & echo  --- Create a New Restore Point --- & echo.
set /p "desc=!cChoice!Enter a description for the new restore point: !cReset!"
if not defined desc set "desc=GN_Manager_Manual_Backup_%date:/=-%_%time::=-%"
echo !cWarning![*] Creating restore point '%desc%'. This may take a minute...!cReset!
powershell -Command "Checkpoint-Computer -Description '%desc%'"
echo !cSuccess![V] Restore point created successfully.!cReset! & echo. & pause & goto MainMenu

:DeletePoint
call :ShowHeader & echo  --- Delete a Restore Point ---
echo.
powershell -Command "Get-ComputerRestorePoint | Format-Table -Property SequenceNumber, Description, CreationTime"
echo. & echo !cError!WARNING: This action is irreversible.!cReset!
set /p "seq=!cChoice!Enter the SequenceNumber of the point to delete (or press Enter to cancel): !cReset!"
if not defined seq goto MainMenu
echo. & echo !cError!Are you absolutely sure you want to delete restore point #%seq%? [Y/N]!cReset!
choice /c YN /n & if errorlevel 2 goto MainMenu
echo !cWarning![*] Deleting restore point #%seq%...!cReset!
powershell -ExecutionPolicy Bypass -Command "$ErrorActionPreference = 'Stop'; try { (Get-ComputerRestorePoint -SequenceNumber %seq%).Delete() } catch { Write-Host 'Error deleting restore point. It might be in use or does not exist.' }"
echo !cSuccess![V] Deletion process finished.!cReset! & echo. & pause & goto MainMenu
