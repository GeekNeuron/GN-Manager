@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                           GN Security Auditor
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
net session >nul 2>nul & if %errorlevel% neq 0 (cls & echo !cError! [!] ERROR: Admin privileges required.!cReset! & powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b)
set "ConfigFile=GN_Manager_Config.ini" & if not exist "%ConfigFile%" (cls & echo !cError!Config file not found! & pause & exit /b)
set "LogFile=GN_Manager_Log.txt" & for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%" ^| findstr /v /b /c:";"') do (set "key=%%a" & set "value=%%b" & if /i "!key!"=="LogFile" set "LogFile=!value!")
if not exist "%LogFile%" (echo [--- Log file created on %DATE% at %TIME% ---] >> "%LogFile%")
echo [%DATE% %TIME%] [--- GN Security Auditor Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ███████╗███████╗ ██████╗ ██████╗ ██╗████████╗!cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██╔════╝██╔════╝██╔════╝██╔═══██╗██║╚══██╔══╝!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     █████╗  █████╗  ██║     ██║   ██║██║   ██║   !cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██╔══╝  ██╔══╝  ██║     ██║   ██║██║   ██║   !cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ███████╗███████╗╚██████╗╚██████╔╝██║   ██║   !cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝   ╚═╝   !cReset!
echo !cTitle!                              Security Auditor                              !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo                   !cTitle!System Security Auditing Tool!cReset!
echo.
echo    [1] Check Open Listening Ports
echo    [2] Review Local Administrator Accounts
echo    [3] Find Unquoted Service Paths (Vulnerability Scan)
echo    [4] Scan Hosts File for Suspicious Entries
echo.
echo    [5] !cSuccess!Export Full Audit Report to Files!cReset!
echo.
echo    [6] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-6): !cReset!"
if "%choice%"=="1" call :CheckPorts
if "%choice%"=="2" call :CheckAdmins
if "%choice%"=="3" call :CheckServices
if "%choice%"=="4" call :CheckHosts
if "%choice%"=="5" call :ExportAudit
if "%choice%"=="6" exit /b
goto MainMenu

:CheckPorts
call :ShowHeader & echo  --- Open Listening Network Ports (TCP) --- & echo.
netstat -anb | find "LISTENING" | find "TCP"
echo. & pause & goto MainMenu

:CheckAdmins
call :ShowHeader & echo  --- Accounts in the Local 'Administrators' Group --- & echo.
net localgroup administrators
echo. & pause & goto MainMenu

:CheckServices
call :ShowHeader & echo  --- Unquoted Service Paths Vulnerability Scan --- & echo.
wmic service where "PathName is not null and PathName not like '\"%' and PathName like '% %'" get Name, PathName, State
echo. & pause & goto MainMenu

:CheckHosts
call :ShowHeader & echo  --- Suspicious Entries in Hosts File --- & echo.
set "HostsFile=%windir%\System32\drivers\etc\hosts"
findstr /v /b /c:"#" /b /c:"127.0.0.1" /b /c:"::1" /b /c:" " /b /c:"" "%HostsFile%"
echo. & echo !cWarning!Any lines above are non-standard. If empty, hosts file is clean.!cReset! & echo. & pause & goto MainMenu

:ExportAudit
call :ShowHeader & echo  --- Export Full Security Audit ---
set "timestamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%" & set "timestamp=!timestamp: =0!"
set "ReportFolder=.\GN_Security_Audit_%timestamp%"
md "%ReportFolder%"
echo !cWarning![*] Generating audit files... please wait.!cReset!
powershell -Command "netstat -anb | find 'LISTENING' | find 'TCP' | Out-File '%ReportFolder%\open_ports.txt' -Encoding utf8"
powershell -Command "net localgroup administrators | Out-File '%ReportFolder%\admin_accounts.txt' -Encoding utf8"
powershell -Command "Get-WmiObject -Class Win32_Service | Where-Object { $_.PathName -and $_.PathName -notlike '`"*' -and $_.PathName -like '* *' } | Select-Object Name, PathName, State | Export-Csv -Path '%ReportFolder%\unquoted_services.csv' -NoTypeInformation -Encoding UTF8"
powershell -Command "Get-Content -Path $env:windir\System32\drivers\etc\hosts | Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() -ne '' } | Export-Csv -Path '%ReportFolder%\hosts_file_entries.csv' -NoTypeInformation -Encoding UTF8"
echo !cSuccess![V] All audit reports have been exported to the folder:!cReset! & echo %cd%\%ReportFolder%
echo. & pause & start "" "%ReportFolder%" & goto MainMenu

:CreateDefaultConfig
(
    echo ; --- GN Manager Suite Configuration ---
) > "%ConfigFile%"
goto :eof
