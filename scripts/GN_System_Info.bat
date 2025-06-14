@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                               GN System Info
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
echo [%DATE% %TIME%] [--- GN System Info Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ███████╗██╗   ██╗███╗   ██╗███████╗ ██████╗ !cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝██╔═══██╗!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ███████╗ ╚████╔╝ ██╔██╗ ██║█████╗  ██║   ██║!cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ╚════██║  ╚██╔╝  ██║╚██╗██║██╔══╝  ██║   ██║!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ███████║   ██║   ██║ ╚████║███████╗╚██████╔╝!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚══════╝   ╚═╝   ╚═╝  ╚═══╝╚══════╝ ╚═════╝ !cReset!
echo !cTitle!                                System Info                                   !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo                 !cTitle!System Information Reporter!cReset!
echo.
echo    [1] OS and System Summary
echo    [2] CPU Information
echo    [3] Memory (RAM) Information
echo    [4] Disk and Storage Information
echo    [5] Graphics Card (GPU) Information
echo    [6] Network Adapters Information
echo.
echo    [7] !cWarning!Show ALL Information (Sequential)!cReset!
echo.
echo    [8] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-8): !cReset!"
if "%choice%"=="1" call :GetOSInfo
if "%choice%"=="2" call :GetCPUInfo
if "%choice%"=="3" call :GetRAMInfo
if "%choice%"=="4" call :GetDiskInfo
if "%choice%"=="5" call :GetGPUInfo
if "%choice%"=="6" call :GetNetworkInfo
if "%choice%"=="7" call :ShowAll
if "%choice%"=="8" exit /b
goto MainMenu

:GetOSInfo
call :ShowHeader & echo  --- OS and System Summary --- & echo.
echo !cSuccess!Operating System:!cReset!
wmic os get Caption, Version, BuildNumber, OSArchitecture, InstallDate, SerialNumber | findstr /r /v "^$"
echo.
echo !cSuccess!Computer System:!cReset!
wmic computersystem get Manufacturer, Model, Name, TotalPhysicalMemory /value
echo.
pause & goto MainMenu

:GetCPUInfo
call :ShowHeader & echo  --- CPU Information --- & echo.
wmic cpu get Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, L3CacheSize, Manufacturer /value
echo.
pause & goto MainMenu

:GetRAMInfo
call :ShowHeader & echo  --- Memory (RAM) Information --- & echo.
echo !cWarning!Listing individual RAM modules:!cReset!
wmic memorychip get BankLabel, Capacity, Speed, Manufacturer, PartNumber | findstr /r /v "^$"
echo.
echo !cSuccess!Total Physical Memory:!cReset!
wmic computersystem get TotalPhysicalMemory /value
echo.
pause & goto MainMenu

:GetDiskInfo
call :ShowHeader & echo  --- Disk and Storage Information --- & echo.
echo !cSuccess!Logical Disks (Partitions):!cReset!
wmic logicaldisk get DeviceID, VolumeName, FileSystem, Size, FreeSpace | findstr /r /v "^$"
echo !cWarning!Note: Size and FreeSpace are in Bytes.!cReset!
echo.
echo !cSuccess!Physical Disk Drives:!cReset!
wmic diskdrive get Model, Size, InterfaceType | findstr /r /v "^$"
echo.
pause & goto MainMenu

:GetGPUInfo
call :ShowHeader & echo  --- Graphics Card (GPU) Information --- & echo.
wmic path win32_videocontroller get Name, DriverVersion, AdapterRAM, VideoProcessor | findstr /r /v "^$"
echo !cWarning!Note: AdapterRAM is in Bytes.!cReset!
echo.
pause & goto MainMenu

:GetNetworkInfo
call :ShowHeader & echo  --- Network Adapters Information --- & echo.
echo !cWarning!Listing enabled IP adapters only:!cReset!
wmic nicconfig where "IPEnabled=true" get Description, IPAddress, IPSubnet, DefaultIPGateway, MACAddress, DNSServerSearchOrder | findstr /r /v "^$"
echo.
pause & goto MainMenu

:ShowAll
call :GetOSInfo
call :GetCPUInfo
call :GetRAMInfo
call :GetDiskInfo
call :GetGPUInfo
call :GetNetworkInfo
goto MainMenu

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
