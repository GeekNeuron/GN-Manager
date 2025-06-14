@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                               GN Tweak Manager
::                           Part of the GN Manager Suite
::
:: Author: GeekNeuron
:: Project: https://github.com/GeekNeuron/GN-Manager
:: WARNING: This tool can compromise system security. Use with extreme caution.
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
echo [%DATE% %TIME%] [--- GN Tweak Manager Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ████████╗██╗    ██╗███████╗ █████╗  ██╗  ██╗!cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ╚══██╔══╝██║    ██║██╔════╝██╔══██╗██║ ██╔╝!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║        ██║   ██║ █╗ ██║█████╗  ███████║█████╔╝ !cReset!
echo !cTitle!██║   ██║██║╚██╗██║        ██║   ██║███╗██║██╔══╝  ██╔══██║██╔═██╗ !cReset!
echo !cTitle!╚██████╔╝██║ ╚████║        ██║   ╚███╔███╔╝███████╗██║  ██║██║  ██╗!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝        ╚═╝    ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝!cReset!
echo !cTitle!                                Tweak Manager                                 !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo               !cError!EXPERT-LEVEL SYSTEM CONFIGURATION TOOL!cReset!
echo.
echo    [1] Windows Defender Toggles
echo    [2] Windows Update Toggles
echo    [3] Windows Firewall Toggles
echo    [4] Explorer ^& UI Toggles
echo.
echo    [5] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-5): !cReset!"
if "%choice%"=="1" goto DefenderMenu
if "%choice%"=="2" goto UpdateMenu
if "%choice%"=="3" goto FirewallMenu
if "%choice%"=="4" goto ExplorerMenu
if "%choice%"=="5" exit /b
goto MainMenu

:: =================================================================================
:: Tweak Menus
:: =================================================================================

:DefenderMenu
call :ShowHeader & echo  --- Windows Defender Toggles ---
set "DefKey=HKLM\SOFTWARE\Policies\Microsoft\Windows Defender"
reg query "%DefKey%" /v "DisableAntiSpyware" | find "0x1" >nul
if %errorlevel% equ 0 (
    echo !cError! Current Status: Defender is DISABLED via policy.!cReset!
) else (
    echo !cSuccess! Current Status: Defender is ENABLED.!cReset!
)
echo. & echo    [1] !cError!Disable Defender!cReset! & echo    [2] !cSuccess!Enable Defender!cReset! & echo. & echo    [3] Back
echo. & set /p "d_choice=!cChoice!Choice: !cReset!"
if "%d_choice%"=="1" call :DisableDefender & goto DefenderMenu
if "%d_choice%"=="2" call :EnableDefender & goto DefenderMenu
if "%d_choice%"=="3" goto MainMenu
goto DefenderMenu

:UpdateMenu
call :ShowHeader & echo  --- Windows Update Toggles ---
sc query wuauserv | find "DISABLED" >nul
if %errorlevel% equ 0 (
    echo !cError! Current Status: Windows Update service is DISABLED.!cReset!
) else (
    echo !cSuccess! Current Status: Windows Update service is ENABLED.!cReset!
)
echo. & echo    [1] !cError!Disable Windows Update (Aggressive)!cReset! & echo    [2] !cSuccess!Enable Windows Update!cReset! & echo. & echo    [3] Back
echo. & set /p "u_choice=!cChoice!Choice: !cReset!"
if "%u_choice%"=="1" call :DisableUpdates & goto UpdateMenu
if "%u_choice%"=="2" call :EnableUpdates & goto UpdateMenu
if "%u_choice%"=="3" goto MainMenu
goto UpdateMenu

:FirewallMenu
call :ShowHeader & echo  --- Windows Firewall Toggles ---
netsh advfirewall show allprofiles | find "State" | find "ON" >nul
if %errorlevel% equ 0 (
    echo !cSuccess! Current Status: Firewall is ON.!cReset!
) else (
    echo !cError! Current Status: Firewall is OFF.!cReset!
)
echo. & echo    [1] !cError!Disable Firewall!cReset! & echo    [2] !cSuccess!Enable Firewall!cReset! & echo. & echo    [3] Back
echo. & set /p "f_choice=!cChoice!Choice: !cReset!"
if "%f_choice%"=="1" call :DisableFirewall & goto FirewallMenu
if "%f_choice%"=="2" call :EnableFirewall & goto FirewallMenu
if "%f_choice%"=="3" goto MainMenu
goto FirewallMenu

:ExplorerMenu
call :ShowHeader & echo  --- Explorer ^& UI Toggles ---
echo. & echo    [1] Show/Hide Hidden Files & echo    [2] Show/Hide File Extensions & echo. & echo    [3] Back
echo. & set /p "e_choice=!cChoice!Choice: !cReset!"
if "%e_choice%"=="1" call :ToggleHiddenFiles & goto ExplorerMenu
if "%e_choice%"=="2" call :ToggleFileExt & goto ExplorerMenu
if "%e_choice%"=="3" goto MainMenu
goto ExplorerMenu

:: =================================================================================
:: Action Subroutines
:: =================================================================================

:DisableDefender
echo. & echo !cError!WARNING: Disabling Windows Defender will leave your system highly vulnerable.!cReset!
echo !cChoice!Are you absolutely sure? [Y/N]!cReset! & choice /c YN /n & if errorlevel 2 goto :eof
echo !cWarning![*] Disabling Windows Defender via registry policy...!cReset!
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul
echo !cSuccess![V] Done. A restart may be required.!cReset! & pause
goto :eof

:EnableDefender
echo. & echo !cWarning![*] Enabling Windows Defender...!cReset!
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /f >nul 2>nul
echo !cSuccess![V] Done. A restart may be required.!cReset! & pause
goto :eof

:DisableUpdates
echo. & echo !cError!WARNING: Disabling Windows Update prevents security patches and can be risky.!cReset!
echo !cChoice!Are you sure? [Y/N]!cReset! & choice /c YN /n & if errorlevel 2 goto :eof
echo !cWarning![*] Disabling Windows Update Service and Policy...!cReset!
sc stop "wuauserv" >nul & sc config "wuauserv" start=disabled >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f >nul
echo !cSuccess![V] Done. A restart is recommended.!cReset! & pause
goto :eof

:EnableUpdates
echo. & echo !cWarning![*] Enabling Windows Update Service and Policy...!cReset!
sc config "wuauserv" start=auto >nul & sc start "wuauserv" >nul
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /f >nul 2>nul
echo !cSuccess![V] Done. A restart is recommended.!cReset! & pause
goto :eof

:DisableFirewall
echo. & echo !cError!WARNING: Disabling the firewall exposes your PC to network threats.!cReset!
echo !cChoice!Are you sure? [Y/N]!cReset! & choice /c YN /n & if errorlevel 2 goto :eof
echo !cWarning![*] Disabling Windows Defender Firewall for all profiles...!cReset!
netsh advfirewall set allprofiles state off
echo !cSuccess![V] Firewall disabled.!cReset! & pause
goto :eof

:EnableFirewall
echo. & echo !cWarning![*] Enabling Windows Defender Firewall for all profiles...!cReset!
netsh advfirewall set allprofiles state on
echo !cSuccess![V] Firewall enabled.!cReset! & pause
goto :eof

:ToggleHiddenFiles
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden | find "0x1" >nul
if %errorlevel% equ 0 (set "choicePrompt=Hidden files are currently SHOWN. Hide them?") else (set "choicePrompt=Hidden files are currently HIDDEN. Show them?")
echo. & echo !cChoice!%choicePrompt% [Y/N]!cReset! & choice /c YN /n & if errorlevel 2 goto :eof
if %errorlevel% equ 1 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f >nul
) else (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 2 /f >nul
)
call :RefreshExplorer & echo !cSuccess![V] Setting applied.!cReset! & pause
goto :eof

:ToggleFileExt
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt | find "0x0" >nul
if %errorlevel% equ 0 (set "choicePrompt=File extensions are currently SHOWN. Hide them?") else (set "choicePrompt=File extensions are currently HIDDEN. Show them?")
echo. & echo !cChoice!%choicePrompt% [Y/N]!cReset! & choice /c YN /n & if errorlevel 2 goto :eof
if %errorlevel% equ 1 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f >nul
) else (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 1 /f >nul
)
call :RefreshExplorer & echo !cSuccess![V] Setting applied.!cReset! & pause
goto :eof

:RefreshExplorer
taskkill /f /im explorer.exe >nul
start explorer.exe
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
