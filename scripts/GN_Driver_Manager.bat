@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                               GN Driver Manager
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
if not exist "%ConfigFile%" call :CreateDefaultConfig
set "LogFile=GN_Manager_Log.txt"
for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%" ^| findstr /v /b /c:";"') do (
    set "key=%%a" & set "value=%%b" & if /i "!key!"=="LogFile" set "LogFile=!value!"
)
if not exist "%LogFile%" (echo [--- Log file created on %DATE% at %TIME% ---] >> "%LogFile%")
echo [%DATE% %TIME%] [--- GN Driver Manager Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ██████╗ ██████╗ ██╗██╗   ██╗███████╗██████╗ !cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██╔══██╗██╔══██╗██║██║   ██║██╔════╝██╔══██╗!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ██║  ██║██████╔╝██║██║   ██║█████╗  ██████╔╝!cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██║  ██║██╔══██╗██║╚██╗ ██╔╝██╔══╝  ██╔══██╗!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ██████╔╝██║  ██║██║ ╚████╔╝ ███████╗██║  ██║!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚══════╝╚═╝  ╚═╝!cReset!
echo !cTitle!                              Driver Manager                                !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo               !cTitle!Driver Diagnosis, Backup, and Restore Toolkit!cReset!
echo.
echo    [1] Diagnose Hardware ^& Find Drivers
echo    [2] Backup All Third-Party Drivers (Export)
echo    [3] Restore Drivers from Backup (Import)
echo    [4] Quick Links to Main Driver Sites
echo.
echo    [5] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-5): !cReset!"
if "%choice%"=="1" goto DiagnoseHardware
if "%choice%"=="2" goto BackupDrivers
if "%choice%"=="3" goto RestoreDrivers
if "%choice%"=="4" goto QuickLinks
if "%choice%"=="5" exit /b
goto MainMenu

:DiagnoseHardware
call :ShowHeader & echo  --- Diagnose Hardware ^& Find Drivers ---
echo !cWarning![*] Scanning for devices with driver issues... Please wait.!cReset! & echo.
set "problemCount=0"
wmic path win32_pnpentity where "ConfigManagerErrorCode <> 0" get Name, PNPDeviceID /format:list > temp_devices.txt
for /f %%i in (temp_devices.txt) do set /a problemCount+=1
if %problemCount% LSS 3 (
    echo !cSuccess![+] No devices with significant driver problems were found.!cReset! & echo. & pause & del temp_devices.txt 2>nul & goto MainMenu
)
type temp_devices.txt
del temp_devices.txt 2>nul
echo !cTitle!-------------------------------------------------------------------------------!cReset!
echo !cError![!] Found devices with potential issues listed above.!cReset!
echo To find the correct driver, copy the !cSuccess!PNPDeviceID!cReset! value for a device
echo (e.g., PCI\VEN_8086^&DEV_A1B1...) and paste it below.
echo.
set /p "DeviceID=!cChoice!Enter PNPDeviceID to search online: !cReset!"
if not defined DeviceID goto MainMenu
set "SearchURL=https://www.google.com/search?q=driver+download+!DeviceID!"
echo !cWarning![*] Opening browser to search for: !DeviceID!...!cReset!
start "" "!SearchURL!"
echo. & pause & goto MainMenu

:BackupDrivers
call :ShowHeader & echo  --- Backup All Third-Party Drivers (Export) ---
set "DefaultBackupPath=C:\GN_Driver_Backup"
echo This tool will export all non-Microsoft drivers to a folder.
echo It is highly recommended before a clean Windows installation.
echo.
set /p "BackupPath=!cChoice!Enter full path for backup folder (Default: %DefaultBackupPath%): !cReset!"
if not defined BackupPath set "BackupPath=%DefaultBackupPath%"
if not exist "%BackupPath%" md "%BackupPath%"
echo !cWarning![*] Exporting drivers to "%BackupPath%"... This may take a significant amount of time.!cReset!
DISM /Online /Export-Driver /Destination:"%BackupPath%"
echo. & echo !cSuccess![V] Driver export completed.!cReset!
echo Your drivers are backed up in: %BackupPath%
echo. & pause & goto MainMenu

:RestoreDrivers
call :ShowHeader & echo  --- Restore Drivers from Backup (Import) ---
echo This tool will install all drivers from a specified backup folder.
echo Use this on a fresh Windows installation to restore your drivers.
echo.
set /p "RestorePath=!cChoice!Enter the full path to your driver backup folder: !cReset!"
if not defined RestorePath goto MainMenu
if not exist "%RestorePath%" (
    echo !cError![!] The specified path does not exist.!cReset! & echo. & pause & goto MainMenu
)
echo !cWarning![*] Adding and installing all drivers from "%RestorePath%"...!cReset!
pnputil /add-driver "%RestorePath%\*.inf" /subdirs /install
echo. & echo !cSuccess![V] Driver restoration process completed.!cReset!
echo Windows has attempted to install all drivers from the backup.
echo. & pause & goto MainMenu

:QuickLinks
call :ShowHeader & echo  --- Quick Links to Main Driver Sites --- & echo.
echo    [1] NVIDIA Drivers (GeForce/RTX)
echo    [2] AMD Drivers (Radeon/Ryzen)
echo    [3] Intel Drivers (Graphics/Chipsets)
echo. & echo    [4] Back to Main Menu
echo.
set /p "l_choice=!cChoice!Enter your choice (1-4): !cReset!"
if "%l_choice%"=="1" start "" "https://www.nvidia.com/Download/index.aspx"
if "%l_choice%"=="2" start "" "https://www.amd.com/en/support"
if "%l_choice%"=="3" start "" "https://www.intel.com/content/www/us/en/download-center/home.html"
if "%l_choice%"=="4" goto MainMenu
goto QuickLinks


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
