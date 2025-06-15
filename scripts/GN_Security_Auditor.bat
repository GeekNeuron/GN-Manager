@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                           GN Security Auditor
::                           Part of the GN Manager Suite
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
echo    [5] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-5): !cReset!"
if "%choice%"=="1" call :CheckPorts
if "%choice%"=="2" call :CheckAdmins
if "%choice%"=="3" call :CheckServices
if "%choice%"=="4" call :CheckHosts
if "%choice%"=="5" exit /b
goto MainMenu

:CheckPorts
call :ShowHeader & echo  --- Open Listening Network Ports (TCP) --- & echo.
echo !cWarning![*] Scanning... This may take a moment.!cReset! & echo.
netstat -anb | find "LISTENING" | find "TCP"
echo. & echo !cWarning!Review the list above for any unrecognized programs listening for connections.!cReset! & echo. & pause & goto MainMenu

:CheckAdmins
call :ShowHeader & echo  --- Accounts in the Local 'Administrators' Group --- & echo.
net localgroup administrators
echo. & echo !cWarning!Ensure all accounts listed above are authorized to have full control.!cReset! & echo. & pause & goto MainMenu

:CheckServices
call :ShowHeader & echo  --- Unquoted Service Paths Vulnerability Scan --- & echo.
echo !cWarning![*] Searching for services with unquoted paths containing spaces...!cReset! & echo.
wmic service where "PathName is not null and PathName not like '\"%' and PathName like '% %'" get Name, PathName, State
echo. & echo !cWarning!Services listed above may be vulnerable to privilege escalation.!cReset! & echo. & pause & goto MainMenu

:CheckHosts
call :ShowHeader & echo  --- Suspicious Entries in Hosts File --- & echo.
set "HostsFile=%windir%\System32\drivers\etc\hosts"
echo !cWarning![*] Scanning %HostsFile%...!cReset! & echo.
findstr /v /b /c:"#" /b /c:"127.0.0.1" /b /c:"::1" /b /c:" " /b /c:"" "%HostsFile%"
echo. & echo !cWarning!Any lines listed above are non-standard entries and should be investigated.!cReset!
echo If no lines are shown, your hosts file appears clean.
echo. & pause & goto MainMenu
