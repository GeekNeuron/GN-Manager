@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                             GN Manager Suite (Launcher)
::                           The main entry point for the suite
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
if not exist "%ConfigFile%" (
    cls & echo !cWarning!Config file not found. Please run one of the main tools first to generate it.!cReset!
    pause & exit /b
)
set "LogFile=GN_Manager_Log.txt"
for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%" ^| findstr /v /b /c:";"') do (
    set "key=%%a" & set "value=%%b" & if /i "!key!"=="LogFile" set "LogFile=!value!"
)
if not exist "%LogFile%" (echo [--- Log file created on %DATE% at %TIME% ---] >> "%LogFile%")
echo [%DATE% %TIME%] [--- GN Manager Suite LAUNCHER Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ███╗   ███╗ █████╗  ███╗   ██╗ ██████╗  ███████╗!cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ████╗ ████║██╔══██╗████╗  ██║██╔═══██╗██╔════╝!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ██╔████╔██║███████║██╔██╗ ██║██║   ██║█████╗  !cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██║╚██╔╝██║██╔══██║██║╚██╗██║██║   ██║██╔══╝  !cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ██║ ╚═╝ ██║██║  ██║██║ ╚████║╚██████╔╝███████╗!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝!cReset!
echo !cTitle!                                  Suite Launcher                                !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo                   !cTitle!Welcome to the GN Manager Suite!cReset!
echo.
echo  !cSuccess!----- Installation & Updates -----!cReset!
echo    [1] GN Winget Manager
echo    [2] GN Local Install Manager
echo.
echo  !cSuccess!----- System Maintenance & Repair -----!cReset!
echo    [3] GN Cleaner Manager
echo    [4] GN Repair Toolkit
echo    [5] GN System Optimizer
echo    [6] !cError!GN Tweak Manager (For Experts)!cReset!
echo.
echo  !cSuccess!----- Analysis & Diagnostics -----!cReset!
echo    [7] GN Disk Analyzer
echo    [8] GN System Info
echo    [9] GN Network Manager
echo.
echo  !cSuccess!----- Data & Driver Management -----!cReset!
echo    [10] GN Backup Manager
echo    [11] GN Driver Manager
echo.
echo  !cTitle!------------------------------------!cReset!
echo    [12] Exit Suite
echo.
set /p "choice=!cChoice!Enter your choice (1-12): !cReset!"

if "%choice%"=="1" call GN_Winget_Manager.bat & goto MainMenu
if "%choice%"=="2" call GN_Local_Install_Manager.bat & goto MainMenu
if "%choice%"=="3" call GN_Cleaner_Manager.bat & goto MainMenu
if "%choice%"=="4" call GN_Repair_Toolkit.bat & goto MainMenu
if "%choice%"=="5" call GN_System_Optimizer.bat & goto MainMenu
if "%choice%"=="6" call GN_Tweak_Manager.bat & goto MainMenu
if "%choice%"=="7" call GN_Disk_Analyzer.bat & goto MainMenu
if "%choice%"=="8" call GN_System_Info.bat & goto MainMenu
if "%choice%"=="9" call GN_Network_Manager.bat & goto MainMenu
if "%choice%"=="10" call GN_Backup_Manager.bat & goto MainMenu
if "%choice%"=="11" call GN_Driver_Manager.bat & goto MainMenu
if "%choice%"=="12" exit /b
goto MainMenu

:CreateDefaultConfig
(
    echo ; --- GN Manager Suite Configuration ---
) > "%ConfigFile%"
goto :eof
