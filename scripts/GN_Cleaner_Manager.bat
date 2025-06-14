@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                               GN Cleaner Manager
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
set "QuarantineDir=.\Cleanup_Quarantine"
set "searchPaths=%ProgramFiles% %ProgramFiles(x86)% %APPDATA% %LOCALAPPDATA% %PROGRAMDATA%"

for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%" ^| findstr /v /b /c:";"') do (
    set "key=%%a" & set "value=%%b"
    if /i "!key!"=="LogFile" set "LogFile=!value!"
    if /i "!key!"=="QuarantineDir" set "QuarantineDir=!value!"
    if /i "!key!"=="SearchPaths" set "searchPaths=!value!"
)
if not exist "%LogFile%" (echo [--- Log file created on %DATE% at %TIME% ---] >> "%LogFile%")
echo [%DATE% %TIME%] [--- GN Cleaner Manager Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ██████╗ ██╗      █████╗ ███╗   ██╗██╗███████╗██████╗ !cReset!
echo !cTitle!██╔════╝ ████╗  ██║    ██╔════╝ ██║     ██╔══██╗████╗  ██║██║██╔════╝██╔══██╗!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║    ██║      ██║     ███████║██╔██╗ ██║██║█████╗  ██████╔╝!cReset!
echo !cTitle!██║   ██║██║╚██╗██║    ██║      ██║     ██╔══██║██║╚██╗██║██║██╔══╝  ██╔══██╗!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║    ╚██████╗ ███████╗██║  ██║██║ ╚████║██║███████╗██║  ██║!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚══════╝╚═╝  ╚═╝!cReset!
echo !cTitle!                              Cleaner Manager                               !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo               !cTitle!Full System Uninstall and Cleanup Tool!cReset!
echo.
echo    [1] Uninstall Program (Legacy Auto-List)
echo    [2] Uninstall Program (via Winget)
echo    [3] Clean Leftover Files (Quarantine)
echo    [4] !cError!Clean Leftover Registry Keys (DANGEROUS)!cReset!
echo.
echo    [5] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-5): !cReset!"
if "%choice%"=="1" goto UninstallSoftware
if "%choice%"=="2" goto WingetUninstall
if "%choice%"=="3" goto CleanupData
if "%choice%"=="4" goto RegistryCleanup
if "%choice%"=="5" exit /b
goto MainMenu

:WingetUninstall
call :ShowHeader & echo  --- Uninstall an application using Winget ---
set /p "packages=!cChoice!Enter Package ID(s) to uninstall: !cReset!" & if not defined packages goto MainMenu
echo [%DATE% %TIME%] Winget Uninstall selected for: %packages%. >> "%LogFile%"
for %%P in (%packages%) do (
    echo. & echo  !cWarning![*] Uninstalling %%P...!cReset!
    winget uninstall --id %%P -e --accept-source-agreements
)
echo. & echo  !cSuccess![V] Uninstallation process finished.!cReset! & pause & goto MainMenu

:CleanupData
call :ShowHeader & echo             !cTitle!CLEAN UP LEFTOVER DATA (SAFE MODE)!cReset!
echo !cSuccess!Folders will be MOVED to the quarantine directory:!cReset! !cWarning!%QuarantineDir%!cReset! & echo.
set /p "keyword=!cChoice!Application keyword: !cReset!" & if "%keyword%"=="" goto MainMenu
echo [%DATE% %TIME%] Cleanup started for keyword: "%keyword%". >> "%LogFile%"
if not exist "%QuarantineDir%" md "%QuarantineDir%"
set "foundCount=0" & echo.
for %%P in (%searchPaths%) do ( if exist "%%P" ( for /f "delims=" %%D in ('dir "%%P\*'""%keyword%""'*" /b /ad') do (
    set /a foundCount+=1 & set "foundPath=%%~fD"
    echo !cTitle!-------------------------------------------------------------------------------!cReset!
    echo !cWarning![!] Found potential leftover folder:!cReset! & echo     !foundPath! & echo.
    echo !cChoice!==> Do you want to MOVE this folder to the quarantine? [Y/N]!cReset! & choice /c YN /n
    if errorlevel 2 ( echo  !cWarning![-] Skipped.!cReset! ) else (
        set "timestamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%" & set "timestamp=!timestamp: =0!"
        set "destName=%%~nxD_!timestamp!"
        echo  !cWarning![*] Moving folder to quarantine as "!destName!"...!cReset! & move "!foundPath!" "%QuarantineDir%\!destName!" >nul
        if exist "!foundPath!" ( echo  !cError![!] ERROR: Failed to move folder.!cReset!) else ( echo  !cSuccess![V] Folder successfully moved.!cReset!)
    )
)))
echo !cTitle!-------------------------------------------------------------------------------!cReset!
if %foundCount% equ 0 ( echo. & echo  !cSuccess![+] No folders matching the keyword were found.!cReset!) else (
    echo. & echo  !cSuccess![+] Process complete. Quarantined folders are in:!cReset! & echo  !cWarning!%cd%\%QuarantineDir%!cReset!
)
echo. & pause & goto MainMenu

:RegistryCleanup
call :ShowHeader & echo                 !cError! --- PERMANENTLY DELETE REGISTRY KEYS --- !cReset!
echo !cError!DANGER! This action is IRREVERSIBLE and can damage your system.!cReset! & echo.
echo !cChoice!Are you absolutely sure you want to proceed? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto MainMenu
set /p "keyword=!cChoice!Enter a keyword to search for: !cReset!" & if not defined keyword goto MainMenu
echo [%DATE% %TIME%] Registry Cleanup started for keyword: "%keyword%". >> "%LogFile%"
echo !cWarning![*] Searching registry... This may take a moment.!cReset!
set "foundCount=0" & set "regHives=HKCU\Software HKLM\SOFTWARE HKLM\SOFTWARE\WOW6432Node"
for %%H in (%regHives%) do ( for /f "delims=" %%K in ('reg query "%%H" /s /f "%keyword%" /k') do (
    set /a foundCount+=1 & echo !cTitle!-------------------------------------------------------------------------------!cReset!
    echo !cError![!] Found potential leftover key:!cReset! %%K
    echo !cError!ARE YOU SURE YOU WANT TO PERMANENTLY DELETE THIS KEY? [Y/N]!cReset! & choice /c YN /n
    if errorlevel 2 ( echo [-] Skipped. ) else (
        echo !cError![*] Deleting key...!cReset! & reg delete "%%K" /f
        reg query "%%K" >nul 2>nul
        if errorlevel 1 ( echo !cSuccess![V] Key deleted successfully.!cReset!) else ( echo !cError![!] FAILED to delete key.!cReset!)
    )
))
echo !cTitle!-------------------------------------------------------------------------------!cReset!
echo !cSuccess![+] Search complete. Found and processed %foundCount% potential keys.!cReset! & pause & goto MainMenu

:UninstallSoftware
call :ShowHeader & echo             !cTitle!UNINSTALL SOFTWARE - AUTOMATIC LIST!cReset! & echo.
echo !cWarning![*] Please wait, generating list of installed programs...!cReset!
set "count=0"
set "RegPath64=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set "RegPath32=HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
:BuildList
for /f "delims=" %%G in ('reg query %1 /k /f "*"') do ( set "DisplayName=" & set "UninstallString="
    for /f "tokens=2,*" %%H in ('reg query "%%G" /v "DisplayName" 2^>nul') do set "DisplayName=%%I"
    for /f "tokens=2,*" %%J in ('reg query "%%G" /v "UninstallString" 2^>nul') do set "UninstallString=%%K"
    if defined DisplayName if defined UninstallString ( set /a count+=1 & set "AppName_!count!=!DisplayName!" & set "UninstallCmd_!count!=!UninstallString!" )
) & goto :eof
call :BuildList %RegPath64% & call :BuildList %RegPath32%
:DisplayList
call :ShowHeader
if %count% equ 0 ( echo !cError![!] No installed programs could be found.!cReset! & pause & goto MainMenu )
echo  Select the program(s) you want to uninstall. & echo.
for /L %%i in (1, 1, %count%) do ( echo  [%%i] !AppName_%%i! )
echo. & echo !cTitle!===============================================================================!cReset!
set /p "selection=!cChoice!Enter number(s): !cReset!" & if not defined selection goto MainMenu
:ChooseUninstallMode
call :ShowHeader & echo  !cTitle!Choose Uninstall Mode!cReset! & echo.
echo    [N] Normal Mode: Run the standard uninstaller. (Safest)
echo    [S] Silent Mode: Attempt to run the uninstaller silently. & echo.
echo !cChoice!Select mode [N]ormal or [S]ilent: !cReset! & choice /c NS /n
if errorlevel 2 (set "uninstallMode=Silent") else (set "uninstallMode=Normal")
echo. & echo  !cWarning!--- Preparing to uninstall in %uninstallMode% Mode ---!cReset! & echo.
for %%N in (%selection%) do ( set "num=%%N"
    if !num! GTR 0 if !num! LEQ %count% (
        set "FinalCommand=!UninstallCmd_!num!!"
        if "!uninstallMode!"=="Silent" ( set "OriginalCommand=!FinalCommand!"
            echo !OriginalCommand! | find /i "MsiExec.exe" >nul && set "FinalCommand=!OriginalCommand! /qn"
            echo !OriginalCommand! | find /i "unins" >nul && set "FinalCommand=!OriginalCommand! /VERYSILENT"
            echo !OriginalCommand! | find /i "uninstall.exe" >nul && set "FinalCommand=!OriginalCommand! /S"
        )
        echo  !cTitle!-------------------------------------------------------------!cReset!
        echo  Program #!num!: !AppName_!num!! & echo !cChoice! ==> Are you sure you want to run this command? [Y/N]!cReset! & choice /c YN /n
        if errorlevel 2 ( echo  !cWarning![-] Uninstall cancelled by user.!cReset!) else (
            echo  !cWarning![*] Executing uninstaller... please wait.!cReset!
            start "Uninstalling !AppName_!num!!" /wait !FinalCommand!
            echo  !cSuccess![V] Uninstaller finished.!cReset!
        )
    )
)
echo. & echo  --- Uninstall process finished --- & pause & goto MainMenu

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
