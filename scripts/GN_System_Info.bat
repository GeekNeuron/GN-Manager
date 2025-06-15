@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                               GN System Info
::                           Part of the GN Manager Suite
::                         (Upgraded with CSV Export)
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
echo                   !cTitle!System Information Reporter!cReset!
echo.
echo    [1] OS and System Summary
echo    [2] CPU Information
echo    [3] Memory (RAM) Information
echo    [4] Disk and Storage Information
echo    [5] Graphics Card (GPU) Information
echo    [6] Network Adapters Information
echo.
echo    [7] !cWarning!Show ALL Information (Sequential)!cReset!
echo    [8] !cSuccess!Export Full Report to CSV Files!cReset!
echo.
echo    [9] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-9): !cReset!"
if "%choice%"=="1" call :GetOSInfo
if "%choice%"=="2" call :GetCPUInfo
if "%choice%"=="3" call :GetRAMInfo
if "%choice%"=="4" call :GetDiskInfo
if "%choice%"=="5" call :GetGPUInfo
if "%choice%"=="6" call :GetNetworkInfo
if "%choice%"=="7" call :ShowAll
if "%choice%"=="8" call :ExportAllToCsv
if "%choice%"=="9" exit /b
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

:ExportAllToCsv
call :ShowHeader & echo  --- Export Full System Report to CSV ---
set "timestamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%" & set "timestamp=!timestamp: =0!"
set "ReportFolder=.\GN_System_Report_%timestamp%"
md "%ReportFolder%"
echo !cWarning![*] Generating CSV reports... please wait.!cReset!
powershell -Command "Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture, InstallDate, SerialNumber | Export-Csv -Path '%ReportFolder%\os_info.csv' -NoTypeInformation -Encoding UTF8"
powershell -Command "Get-WmiObject -Class Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed | Export-Csv -Path '%ReportFolder%\cpu_info.csv' -NoTypeInformation -Encoding UTF8"
powershell -Command "Get-WmiObject -Class Win32_PhysicalMemory | Select-Object BankLabel, @{Name='Capacity(GB)';E={[math]::Round($_.Capacity / 1GB, 2)}}, Speed, Manufacturer, PartNumber | Export-Csv -Path '%ReportFolder%\ram_info.csv' -NoTypeInformation -Encoding UTF8"
powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, VolumeName, FileSystem, @{Name='Size(GB)';E={[math]::Round($_.Size / 1GB, 2)}}, @{Name='FreeSpace(GB)';E={[math]::Round($_.FreeSpace / 1GB, 2)}} | Export-Csv -Path '%ReportFolder%\disk_info.csv' -NoTypeInformation -Encoding UTF8"
powershell -Command "Get-WmiObject -Class Win32_VideoController | Select-Object Name, DriverVersion, @{Name='AdapterRAM(MB)';E={[math]::Round($_.AdapterRAM / 1MB, 2)}} | Export-Csv -Path '%ReportFolder%\gpu_info.csv' -NoTypeInformation -Encoding UTF8"
powershell -Command "Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' | Select-Object Description, IPAddress, MACAddress | Export-Csv -Path '%ReportFolder%\network_info.csv' -NoTypeInformation -Encoding UTF8"
echo !cSuccess![V] All system reports have been exported to the folder:!cReset! & echo %cd%\%ReportFolder%
echo. & pause & start "" "%ReportFolder%" & goto MainMenu

:CreateDefaultConfig
(
    echo ; --- GN Manager Suite Configuration ---
) > "%ConfigFile%"
goto :eof
