@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                               GN Repair Toolkit
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
echo [%DATE% %TIME%] [--- GN Repair Toolkit Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ██████╗ ███████╗██████╗  ██╗██████╗ ██╗  ██╗!cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██╔══██╗██╔════╝██╔══██╗██║██╔══██╗██║  ██║!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ██████╔╝█████╗  ██████╔╝██║██║  ██║███████║!cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██╔══██╗██╔══╝  ██╔═══╝ ██║██║  ██║██╔══██║!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ██║  ██║███████╗██║     ██║██████╔╝██║  ██║!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═════╝ ╚═╝  ╚═╝!cReset!
echo !cTitle!                                Repair Toolkit                                !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo                 !cTitle!System and Network Troubleshooting!cReset!
echo.
echo    [1] Network Repair Toolkit
echo    [2] System Integrity Toolkit
echo.
echo    [3] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-3): !cReset!"
if "%choice%"=="1" goto NetworkRepairMenu
if "%choice%"=="2" goto SystemIntegrityMenu
if "%choice%"=="3" exit /b
goto MainMenu

:: =================================================================================
:: Section 1: Network Repair
:: =================================================================================
:NetworkRepairMenu
call :ShowHeader & echo  --- Network Repair Toolkit --- & echo.
echo    [1] Flush ^& Re-register DNS
echo    [2] Release ^& Renew IP Address
echo    [3] Reset Proxy Settings (from Control Panel)
echo    [4] !cWarning!Reset TCP/IP Stack (Advanced)!cReset!
echo    [5] !cWarning!Reset Winsock Catalog (Advanced)!cReset!
echo    [6] !cError!Run ALL Network Resets (Powerful)!cReset!
echo.
echo    [7] Back to Main Menu
echo.
set /p "n_choice=!cChoice!Enter your choice (1-7): !cReset!"
if "%n_choice%"=="1" call :FlushDNS
if "%n_choice%"=="2" call :RenewIP
if "%n_choice%"=="3" call :ResetProxy
if "%n_choice%"=="4" call :ResetTCPIP
if "%n_choice%"=="5" call :ResetWinsock
if "%n_choice%"=="6" call :ResetAllNetwork
if "%n_choice%"=="7" goto MainMenu
goto NetworkRepairMenu

:FlushDNS
echo. & echo !cWarning![*] Flushing and re-registering DNS...!cReset!
ipconfig /flushdns >nul
ipconfig /registerdns >nul
echo !cSuccess![V] DNS cache has been flushed and re-registered.!cReset!
echo. & pause & goto NetworkRepairMenu

:RenewIP
echo. & echo !cWarning![*] Releasing and renewing IP address...!cReset!
ipconfig /release >nul
ipconfig /renew
echo !cSuccess![V] IP address has been renewed.!cReset!
echo. & pause & goto NetworkRepairMenu

:ResetProxy
echo. & echo !cWarning![*] Clearing system-wide proxy settings (from Internet Options)...!cReset!
set "RegKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
reg add "%RegKey%" /v ProxyEnable /t REG_DWORD /d 0 /f >nul
reg delete "%RegKey%" /v ProxyServer /f >nul 2>nul
reg delete "%RegKey%" /v ProxyOverride /f >nul 2>nul
echo !cSuccess![V] Proxy settings have been disabled and cleared.!cReset!
echo. & pause & goto NetworkRepairMenu

:ResetTCPIP
echo. & echo !cError!WARNING: This will reset the TCP/IP stack to its default state.!cReset!
echo !cChoice!Are you sure you want to continue? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto NetworkRepairMenu
echo. & echo !cWarning![*] Resetting TCP/IP stack... A restart may be required.!cReset!
netsh int ip reset
echo !cSuccess![V] TCP/IP stack has been reset.!cReset!
echo. & pause & goto NetworkRepairMenu

:ResetWinsock
echo. & echo !cError!WARNING: This will reset the Winsock catalog. It may affect some network-related applications.!cReset!
echo !cChoice!Are you sure you want to continue? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto NetworkRepairMenu
echo. & echo !cWarning![*] Resetting Winsock catalog... A restart may be required.!cReset!
netsh winsock reset
echo !cSuccess![V] Winsock catalog has been reset.!cReset!
echo. & pause & goto NetworkRepairMenu

:ResetAllNetwork
echo. & echo !cError!WARNING: You are about to run ALL network repair actions sequentially.!cReset!
echo !cError!This is a powerful option and may require a system restart.!cReset!
echo !cChoice!Are you absolutely sure you want to continue? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto NetworkRepairMenu
call :FlushDNS
call :RenewIP
call :ResetProxy
call :ResetTCPIP
call :ResetWinsock
echo. & echo !cSuccess!All network repair actions have been completed.!cReset!
echo. & pause & goto NetworkRepairMenu

:: =================================================================================
:: Section 2: System Integrity
:: =================================================================================
:SystemIntegrityMenu
call :ShowHeader & echo  --- System Integrity Toolkit --- & echo.
echo    [1] Rebuild Icon Cache
echo    [2] !cWarning!Clear Windows Update Cache!cReset!
echo    [3] !cWarning!Run System File Checker (SFC Scan)!cReset!
echo    [4] !cWarning!Run DISM Component Store Repair!cReset!
echo.
echo    [5] Back to Main Menu
echo.
set /p "s_choice=!cChoice!Enter your choice (1-5): !cReset!"
if "%s_choice%"=="1" call :RebuildIconCache
if "%s_choice%"=="2" call :ClearUpdateCache
if "%s_choice%"=="3" call :RunSFC
if "%s_choice%"=="4" call :RunDISM
if "%s_choice%"=="5" goto MainMenu
goto SystemIntegrityMenu

:RebuildIconCache
echo. & echo !cWarning![*] Rebuilding the icon cache... Your desktop will refresh.!cReset!
taskkill /f /im explorer.exe >nul
del /a /q "%localappdata%\IconCache.db" >nul 2>nul
start explorer.exe
echo !cSuccess![V] Icon cache has been rebuilt.!cReset!
echo. & pause & goto SystemIntegrityMenu

:ClearUpdateCache
echo. & echo !cError!WARNING: This will stop the Windows Update service and delete its cache.!cReset!
echo !cChoice!Are you sure you want to continue? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto SystemIntegrityMenu
echo. & echo !cWarning![*] Stopping services...!cReset!
net stop wuauserv >nul
net stop bits >nul
echo !cWarning![*] Deleting cache folder: %windir%\SoftwareDistribution!cReset!
rd /s /q "%windir%\SoftwareDistribution"
echo !cWarning![*] Restarting services...!cReset!
net start wuauserv >nul
net start bits >nul
echo !cSuccess![V] Windows Update cache has been cleared.!cReset!
echo. & pause & goto SystemIntegrityMenu

:RunSFC
echo. & echo !cWarning!Starting System File Checker. This process can take a long time and cannot be cancelled.!cReset!
echo !cChoice!Do you want to start the scan now? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto SystemIntegrityMenu
echo. & sfc /scannow
echo !cSuccess![V] SFC scan completed. Please review the results above.!cReset!
echo. & pause & goto SystemIntegrityMenu

:RunDISM
echo. & echo !cWarning!Starting DISM Component Store Repair. This process can take a long time.!cReset!
echo !cChoice!Do you want to start the repair now? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto SystemIntegrityMenu
echo. & DISM /Online /Cleanup-Image /RestoreHealth
echo !cSuccess![V] DISM process completed. Please review the results above.!cReset!
echo. & pause & goto SystemIntegrityMenu

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
