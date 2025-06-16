@echo off
setlocal enabledelayedexpansion

:: Enable ANSI codes for older Windows
reg query "HKCU\Console" /v VirtualTerminalLevel >nul 2>&1
if %errorlevel% neq 0 (
    reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 0x1 /f >nul
)

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
echo !cTitle!       ██████╗ ███╗   ██╗     ███████╗██╗   ██╗███╗   ██╗███████╗ ██████╗ !cReset!
echo !cTitle!      ██╔════╝ ████╗  ██║     ██╔════╝╚██╗ ██╔╝████╗  ██║██╔════╝██╔═══██╗!cReset!
echo !cTitle!      ██║  ███╗██╔██╗ ██║     ███████╗ ╚████╔╝ ██╔██╗ ██║█████╗  ██║   ██║!cReset!
echo !cTitle!      ██║   ██║██║╚██╗██║     ╚════██║  ╚██╔╝  ██║╚██╗██║██╔══╝  ██║   ██║!cReset!
echo !cTitle!      ╚██████╔╝██║ ╚████║     ███████║   ██║   ██║ ╚████║███████╗╚██████╔╝!cReset!
echo !cTitle!       ╚═════╝ ╚═╝  ╚═══╝     ╚══════╝   ╚═╝   ╚═╝  ╚═══╝╚══════╝ ╚═════╝ !cReset!
echo !cTitle!                                System Info                                   !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron           Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo [1] OS and System Summary
echo [2] CPU Information
echo [3] RAM Information
echo [4] Disk Information
echo [5] GPU Information
echo [6] Network Information
echo [7] Show All Information
echo [8] Export Report to CSV
echo [9] Exit
echo.

set /p "choice=!cChoice!Enter your choice (1-9): !cReset!"
if "%choice%"=="1" goto GetOSInfo
if "%choice%"=="2" goto GetCPUInfo
if "%choice%"=="3" goto GetRAMInfo
if "%choice%"=="4" goto GetDiskInfo
if "%choice%"=="5" goto GetGPUInfo
if "%choice%"=="6" goto GetNetworkInfo
if "%choice%"=="7" goto ShowAll
if "%choice%"=="8" goto ExportAllToCsv
if "%choice%"=="9" exit /b
goto MainMenu

:GetOSInfo
cls
echo --- OS and System Summary ---
wmic os get Caption, Version, BuildNumber, OSArchitecture, InstallDate, SerialNumber | findstr /r /v "^$"
echo.
pause
goto MainMenu

:GetCPUInfo
cls
echo --- CPU Information ---
wmic cpu get Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, L3CacheSize, Manufacturer /value
echo.
pause
goto MainMenu

:GetRAMInfo
cls
echo --- Memory (RAM) Information ---
wmic memorychip get BankLabel, Capacity, Speed, Manufacturer, PartNumber | findstr /r /v "^$"
echo.
wmic computersystem get TotalPhysicalMemory /value
echo.
pause
goto MainMenu

:GetDiskInfo
cls
echo --- Disk Information ---
wmic logicaldisk get DeviceID, VolumeName, FileSystem, Size, FreeSpace | findstr /r /v "^$"
wmic diskdrive get Model, Size, InterfaceType | findstr /r /v "^$"
echo.
pause
goto MainMenu

:GetGPUInfo
cls
echo --- GPU Information ---
wmic path win32_videocontroller get Name, DriverVersion, AdapterRAM, VideoProcessor | findstr /r /v "^$"
echo.
pause
goto MainMenu

:GetNetworkInfo
cls
echo --- Network Information ---
wmic nicconfig where "IPEnabled=true" get Description, IPAddress, IPSubnet, DefaultIPGateway, MACAddress, DNSServerSearchOrder | findstr /r /v "^$"
echo.
pause
goto MainMenu

:ShowAll
call :GetOSInfo
call :GetCPUInfo
call :GetRAMInfo
call :GetDiskInfo
call :GetGPUInfo
call :GetNetworkInfo
goto MainMenu

:ExportAllToCsv
cls
echo --- Exporting System Report ---
set "timestamp=%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=!timestamp: =0!"
set "UserName=%USERNAME%"
set "ReportFolder=C:\Users\!UserName!\GN\GN_System_Report_!timestamp!"
md "%ReportFolder%"
if not exist "%ReportFolder%" (
    echo !cError![!] Failed to create report folder! & pause & goto MainMenu
)
echo !cWarning![*] Generating CSV reports... please wait.!cReset!
powershell -Command "try { Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture, InstallDate, SerialNumber | Export-Csv -Path '%ReportFolder%\os_info.csv' -NoTypeInformation -Encoding UTF8 } catch { echo !cError![!] Error exporting os_info.csv: $_!cReset! }"
powershell -Command "try { Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed | Export-Csv -Path '%ReportFolder%\cpu_info.csv' -NoTypeInformation -Encoding UTF8 } catch { echo !cError![!] Error exporting cpu_info.csv: $_!cReset! }"
powershell -Command "try { Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object BankLabel, @{Name='Capacity(GB)';E={[math]::Round($_.Capacity / (1024*1024*1024), 2)}}, Speed, Manufacturer, PartNumber | Export-Csv -Path '%ReportFolder%\ram_info.csv' -NoTypeInformation -Encoding UTF8 } catch { echo !cError![!] Error exporting ram_info.csv: $_!cReset! }"
powershell -Command "try { Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object DeviceID, VolumeName, FileSystem, @{Name='Size(GB)';E={[math]::Round($_.Size / (1024*1024*1024), 2)}}, @{Name='FreeSpace(GB)';E={[math]::Round($_.FreeSpace / (1024*1024*1024), 2)}} | Export-Csv -Path '%ReportFolder%\disk_info.csv' -NoTypeInformation -Encoding UTF8 } catch { echo !cError![!] Error exporting disk_info.csv: $_!cReset! }"
powershell -Command "try { Get-CimInstance -ClassName Win32_VideoController | Select-Object Name, DriverVersion, @{Name='AdapterRAM(MB)';E={[math]::Round($_.AdapterRAM / (1024*1024), 2)}} | Export-Csv -Path '%ReportFolder%\gpu_info.csv' -NoTypeInformation -Encoding UTF8 } catch { echo !cError![!] Error exporting gpu_info.csv: $_!cReset! }"
powershell -Command "try { Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' | Select-Object Description, IPAddress, MACAddress | Export-Csv -Path '%ReportFolder%\network_info.csv' -NoTypeInformation -Encoding UTF8 } catch { echo !cError![!] Error exporting network_info.csv: $_!cReset! }"
echo !cSuccess!Export complete: %ReportFolder%!cReset!
pause
goto MainMenu

:CreateDefaultConfig
(
    echo ; --- GN Manager Suite Configuration ---
    echo LogFile=GN_Manager_Log.txt
    echo UsePowerShell=true
) > "%ConfigFile%"
goto :eof

:end
endlocal
exit /b
