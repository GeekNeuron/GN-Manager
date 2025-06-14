@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                            GN Winget Install Manager
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
    set "key=%%a" & set "value=%%b"
    if /i "!key!"=="LogFile" set "LogFile=!value!"
)
if not exist "%LogFile%" (echo [--- Log file created on %DATE% at %TIME% ---] >> "%LogFile%")
echo [%DATE% %TIME%] [--- GN Winget Install Manager Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ██╗   ██╗██╗███╗   ██╗████████╗!cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██║   ██║██║████╗  ██║╚══██╔══╝!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ██║   ██║██║██╔██╗ ██║   ██║   !cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██║   ██║██║██║╚██╗██║   ██║   !cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ╚██████╔╝██║██║ ╚████║   ██║   !cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝      ╚═════╝ ╚═╝╚═╝  ╚═══╝   ╚═╝   !cReset!
echo !cTitle!                          Winget Install Manager                          !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo               !cTitle!Winget - Modern Software Management!cReset!
echo.
echo    [1] Search for an application
echo    [2] Install application(s)
echo    [3] Upgrade installed applications
echo.
echo    [4] Exit
echo.
set /p "w_choice=!cChoice!Enter your choice (1-4): !cReset!"
if "%w_choice%"=="1" goto WingetSearch
if "%w_choice%"=="2" goto WingetInstall
if "%w_choice%"=="3" goto WingetUpgrade
if "%w_choice%"=="4" exit /b
goto MainMenu

:WingetSearch
call :ShowHeader & echo  --- Search for an application ---
set /p "query=!cChoice!Enter search term: !cReset!" & if not defined query goto MainMenu
echo [%DATE% %TIME%] Winget Search for: "%query%". >> "%LogFile%" & echo.
winget search "%query%"
echo. & pause & goto MainMenu

:WingetInstall
call :ShowHeader & echo  --- Install application(s) ---
echo  You need the "Package ID" (e.g., VideoLAN.VLC, Google.Chrome).
set /p "packages=!cChoice!Enter Package ID(s) to install: !cReset!" & if not defined packages goto MainMenu
echo [%DATE% %TIME%] Winget Install selected for: %packages%. >> "%LogFile%"
for %%P in (%packages%) do (
    echo. & echo  !cWarning![*] Installing %%P...!cReset!
    echo [%DATE% %TIME%] Attempting to install %%P. >> "%LogFile%"
    winget install --id %%P -e --accept-source-agreements --accept-package-agreements
)
echo. & echo  !cSuccess![V] Installation process finished.!cReset! & pause & goto MainMenu

:WingetUpgrade
call :ShowHeader & echo  --- Upgrade installed applications ---
echo  !cWarning![*] Checking for available upgrades... please wait.!cReset! & echo.
winget upgrade & echo. & echo  !cTitle!-------------------------------------------------------------!cReset!
echo !cChoice!Upgrade [A]ll, choose [Y]es to select specific ones, or [C]ancel? !cReset!
choice /c AYC /n
if errorlevel 3 echo [%DATE% %TIME%] User cancelled upgrade. >> "%LogFile%" && goto MainMenu
if errorlevel 2 echo [%DATE% %TIME%] User chose to upgrade specific packages. >> "%LogFile%" && goto WingetUpgradeSpecific
if errorlevel 1 echo [%DATE% %TIME%] User chose to upgrade all packages. >> "%LogFile%" && goto WingetUpgradeAll

:WingetUpgradeAll
echo. & echo  !cWarning![*] Upgrading all packages... This may take a while.!cReset!
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements
echo. & echo  !cSuccess![V] All possible upgrades have been completed.!cReset!
echo [%DATE% %TIME%] Winget upgrade all command finished. >> "%LogFile%" & pause & goto MainMenu

:WingetUpgradeSpecific
echo. & set /p "packages=!cChoice!Enter Package ID(s) to upgrade: !cReset!" & if not defined packages goto MainMenu
echo [%DATE% %TIME%] User selected specific packages to upgrade: %packages%. >> "%LogFile%"
for %%P in (%packages%) do (
    echo. & echo  !cWarning![*] Upgrading %%P...!cReset!
    winget upgrade --id %%P -e --silent --accept-source-agreements
)
echo. & echo  !cSuccess![V] Selected upgrades have been completed.!cReset! & pause & goto MainMenu

:CreateDefaultConfig
(
    echo ; --- GN Manager Suite Configuration ---
    echo ;
    echo ; -- General Settings --
    echo LogFile=GN_Manager_Log.txt
    echo ;
    echo ; -- Cleaner Manager Settings --
    echo QuarantineDir=.\Cleanup_Quarantine
    echo SearchPaths=%%ProgramFiles%% %%ProgramFiles(x86)%% %%APPDATA%% %%LOCALAPPDATA%% %%PROGRAMDATA%%
    echo ;
    echo ; -- Backup Manager Settings --
    echo BackupDir=.\Application_Backups
    echo ;
    echo ; --- Application Data Profiles for Backup Manager ---
    echo ; Use format: [Profile:AppName] then Key=Path. Use %%USERPROFILE%%.
    echo ;[Profile:VSCode]
    echo ;Extensions=%%USERPROFILE%%\.vscode\extensions
    echo ;UserSettings=%%USERPROFILE%%\AppData\Roaming\Code\User
) > "%ConfigFile%"
goto :eof

