@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                               GN Network Manager
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
echo [%DATE% %TIME%] [--- GN Network Manager Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗  ██████╗ !cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔═══██╗!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██║   ██║!cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██║   ██║!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝╚██████╔╝!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝  ╚═════╝ !cReset!
echo !cTitle!                             Network Manager                                  !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo               !cTitle!Network Diagnostics and Analysis Toolkit!cReset!
echo.
echo    [1] Ping Test
echo    [2] Traceroute
echo    [3] Domain ^& DNS Analysis
echo    [4] View Active Network Connections
echo    [5] Internet Speed Test
echo    [6] Network Helper Tools
echo.
echo    [7] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-7): !cReset!"
if "%choice%"=="1" goto PingTest
if "%choice%"=="2" goto TracerouteTest
if "%choice%"=="3" goto DomainAnalysisMenu
if "%choice%"=="4" goto Netstat
if "%choice%"=="5" goto SpeedTest
if "%choice%"=="6" goto HelperToolsMenu
if "%choice%"=="7" exit /b
goto MainMenu

:PingTest
call :ShowHeader & echo  --- Ping Test ---
set /p "host=!cChoice!Enter a domain or IP to ping (e.g., google.com): !cReset!" & if not defined host goto MainMenu
echo. & ping %host% & echo. & pause & goto MainMenu

:TracerouteTest
call :ShowHeader & echo  --- Traceroute ---
set /p "host=!cChoice!Enter a domain or IP to trace (e.g., google.com): !cReset!" & if not defined host goto MainMenu
echo. & tracert %host% & echo. & pause & goto MainMenu

:Netstat
call :ShowHeader & echo  --- Active Network Connections ---
echo !cWarning![*] Listing all active TCP/UDP connections and listening ports...!cReset! & echo.
netstat -an
echo. & pause & goto MainMenu

:SpeedTest
call :ShowHeader & echo  --- Internet Speed Test ---
echo !cWarning![*] Checking for Speedtest CLI...!cReset!
where speedtest.exe >nul 2>nul
if %errorlevel% equ 0 (
    echo !cSuccess![+] Speedtest CLI found. Running test...!cReset! & echo.
    speedtest.exe
) else (
    echo !cError![!] Speedtest CLI not found on this system.!cReset!
    echo To use this feature, Ookla's official Speedtest CLI is required.
    echo !cChoice!Would you like to try installing it now using Winget? [Y/N]!cReset!
    choice /c YN /n
    if errorlevel 2 goto MainMenu
    echo. & echo !cWarning![*] Attempting to install 'Ookla.SpeedtestCli' via Winget...!cReset!
    winget install --id Ookla.SpeedtestCli -e --accept-source-agreements
    echo. & echo !cWarning![*] Please re-run the Speed Test option if installation was successful.!cReset!
)
echo. & pause & goto MainMenu

:HelperToolsMenu
call :ShowHeader & echo  --- Network Helper Tools ---
echo.
echo    [1] Flush DNS Cache
echo    [2] View Full IP Configuration
echo.
echo    [3] Back to Main Menu
echo.
set /p "h_choice=!cChoice!Enter your choice (1-3): !cReset!"
if "%h_choice%"=="1" (ipconfig /flushdns & echo. & echo !cSuccess![V] DNS resolver cache flushed successfully.!cReset! & pause & goto MainMenu)
if "%h_choice%"=="2" (ipconfig /all & echo. & pause & goto MainMenu)
if "%h_choice%"=="3" goto MainMenu
goto HelperToolsMenu

:DomainAnalysisMenu
call :ShowHeader & echo  --- Domain ^& DNS Analysis ---
set /p "domain=!cChoice!Enter a domain name to analyze (e.g., google.com): !cReset!" & if not defined domain goto MainMenu
:DomainSubMenu
call :ShowHeader & echo  !cTitle!Analyzing Domain:!cReset! !cSuccess!%domain%!cReset!
echo.
echo    [1] Basic DNS Lookup (A, AAAA records)
echo    [2] Mail Server (MX) Records
echo    [3] Name Server (NS) Records
echo    [4] Text (TXT) Records
echo    [5] !cWarning!WHOIS Lookup (Ownership Info)!cReset!
echo.
echo    [6] Back to Network Menu
echo.
set /p "d_choice=!cChoice!Enter your choice (1-6): !cReset!"
if "%d_choice%"=="1" (nslookup %domain% & echo. & pause & goto DomainSubMenu)
if "%d_choice%"=="2" (nslookup -type=mx %domain% & echo. & pause & goto DomainSubMenu)
if "%d_choice%"=="3" (nslookup -type=ns %domain% & echo. & pause & goto DomainSubMenu)
if "%d_choice%"=="4" (nslookup -type=txt %domain% & echo. & pause & goto DomainSubMenu)
if "%d_choice%"=="5" call :LookupWHOIS %domain% & pause & goto DomainSubMenu
if "%d_choice%"=="6" goto MainMenu
goto DomainSubMenu

:LookupWHOIS
call :ShowHeader & echo  --- WHOIS Lookup for %1 ---
echo !cWarning![*] Checking for whois.exe utility...!cReset!
where whois.exe >nul 2>nul
if %errorlevel% equ 0 (
    echo !cSuccess![+] whois.exe found. Retrieving data...!cReset! & echo.
    whois.exe -v %1
) else (
    echo !cError![!] Microsoft 'whois.exe' not found on this system.!cReset!
    echo This is a free, official tool from the Sysinternals suite.
    echo Please download it from the link below and place it in a folder
    echo that is in your system's PATH (e.g., C:\Windows\System32).
    echo.
    echo !cSuccess%Link: https://learn.microsoft.com/en-us/sysinternals/downloads/whois%cReset!
)
goto :eof

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
