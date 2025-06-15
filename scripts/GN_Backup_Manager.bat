@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                               GN Backup Manager
::                           Part of the GN Manager Suite
::                       (Upgraded with 7-Zip Compression)
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
set "BackupDir=.\Application_Backups"

for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%" ^| findstr /v /b /c:";"') do (
    set "key=%%a" & set "value=%%b"
    if /i "!key!"=="LogFile" set "LogFile=!value!"
    if /i "!key!"=="BackupDir" set "BackupDir=!value!"
)
if not exist "%LogFile%" (echo [--- Log file created on %DATE% at %TIME% ---] >> "%LogFile%")
echo [%DATE% %TIME%] [--- GN Backup Manager Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ !cReset!
echo !cTitle!██╔════╝ ████╗  ██║    ██╔═══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔══██╗!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║    ██║   ██║███████║██║     ███████║███████║██████╔╝!cReset!
echo !cTitle!██║   ██║██║╚██╗██║    ██║   ██║██╔══██║██║     ██╔══██║██╔══██║██╔══██╗!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║    ╚██████╔╝██╔══██║╚██████╗██║  ██║██║  ██║██║  ██║!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝!cReset!
echo !cTitle!                              Backup Manager                                !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo               !cTitle!Application Data and Registry Backup / Restore Tool!cReset!
echo.
echo    [1] Export (Backup) Application Data
echo    [2] Import (Restore) Application Data
echo    [3] Backup (Export) Registry Keys
echo.
echo    [4] Exit
echo.
set /p "d_choice=!cChoice!Enter your choice (1-4): !cReset!"
if "%d_choice%"=="1" goto ExportData
if "%d_choice%"=="2" goto ImportData
if "%d_choice%"=="3" goto RegistryBackup
if "%d_choice%"=="4" exit /b
goto MainMenu

:ExportData
call :ShowHeader & echo  --- Export Application Data ---
if not exist "%BackupDir%" md "%BackupDir%"
echo. & echo  Available Profiles in %ConfigFile%:
set "profileCount=0"
for /f "tokens=2 delims=[]" %%P in ('findstr /b /c:"[Profile:" "%ConfigFile%"') do (
    set /a profileCount+=1 & set "Profile_!profileCount!=%%P" & echo  !cSuccess![!profileCount!] %%P!cReset!
)
if %profileCount% equ 0 ( echo !cError![!] No profiles found in '%ConfigFile%'.!cReset! & pause & goto MainMenu)
echo. & set /p "p_choice=!cChoice!Choose a profile number to export: !cReset!"
if "%p_choice%"=="" goto MainMenu
if %p_choice% LEQ 0 if %p_choice% GTR %profileCount% goto ExportData

call :ShowHeader & echo --- Choose Backup Format ---
echo.
echo    [1] Standard Folder Backup (Fast, larger size)
echo    [2] Compressed Archive (.7z) (Slower, smaller size, requires 7-Zip)
echo.
set /p "formatChoice=!cChoice!Enter your choice (1-2): !cReset!"
if "%formatChoice%"=="1" goto ExportDataFolder
if "%formatChoice%"=="2" goto ExportData7z
goto ExportData

:ExportDataFolder
set "SelectedProfile=!Profile_%p_choice%!"
set "timestamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%" & set "timestamp=!timestamp: =0!"
set "FullBackupPath=%BackupDir%\%SelectedProfile%_DATA_%timestamp%" & md "%FullBackupPath%"
echo. & echo !cWarning![*] Starting folder export for profile '!SelectedProfile!' to:!cReset! & echo !FullBackupPath!
set "inSection="
for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%"') do (
    if "!inSection!"=="true" ( if "%%a" LSS "[Profile:" (
        set "key=%%a" & set "path=%%b" & set "path=!path:%%USERPROFILE%%=%USERPROFILE%!"
        echo !cTitle!-------------------------------------------------------------------------------!cReset!
        echo  [*] Backing up '!key!' from '!path!'
        robocopy "!path!" "%FullBackupPath%\!key!" /E /R:2 /W:5 /NFL /NDL /NJH /NJS /nc /ns /np > nul
    ) else ( set "inSection=" ))
    if /i "%%a"=="[Profile:!SelectedProfile!]" set "inSection=true"
)
echo !cTitle!-------------------------------------------------------------------------------!cReset!
echo !cSuccess![V] Folder export for profile '!SelectedProfile!' completed successfully.!cReset! & pause & goto MainMenu

:ExportData7z
call :ShowHeader & echo --- Compressed Archive Export (.7z) ---
where 7z.exe >nul 2>nul
if %errorlevel% neq 0 (
    echo. & echo !cError![!] 7-Zip command-line tool (7z.exe) not found.!cReset!
    echo !cChoice!Would you like to try installing it now using Winget? [Y/N]!cReset!
    choice /c YN /n & if errorlevel 2 goto MainMenu
    winget install 7zip.7zip & pause & goto MainMenu
)
set "SelectedProfile=!Profile_%p_choice%!"
set "timestamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%" & set "timestamp=!timestamp: =0!"
set "TempBackupPath=%BackupDir%\TEMP_%SelectedProfile%_%timestamp%" & md "%TempBackupPath%"
set "FinalArchive=%BackupDir%\%SelectedProfile%_DATA_%timestamp%.7z"
echo. & echo !cWarning![*] Starting compressed export for profile '!SelectedProfile!'...!cReset!
echo !cWarning!    Step 1 of 2: Copying files to a temporary location...!cReset!
set "inSection="
for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%"') do (
    if "!inSection!"=="true" ( if "%%a" LSS "[Profile:" (
        set "key=%%a" & set "path=%%b" & set "path=!path:%%USERPROFILE%%=%USERPROFILE%!"
        robocopy "!path!" "%TempBackupPath%\!key!" /E /R:2 /W:5 /NFL /NDL /NJH /NJS /nc /ns /np > nul
    ) else ( set "inSection=" ))
    if /i "%%a"=="[Profile:!SelectedProfile!]" set "inSection=true"
)
echo !cWarning!    Step 2 of 2: Compressing files into '%FinalArchive%'... This may take time.!cReset!
7z.exe a -t7z "%FinalArchive%" "%TempBackupPath%\*" > nul
rd /s /q "%TempBackupPath%"
echo !cTitle!-------------------------------------------------------------------------------!cReset!
echo !cSuccess![V] Compressed export completed successfully.!cReset! & pause & goto MainMenu


:ImportData
call :ShowHeader & echo  --- Import Application Data ---
if not exist "%BackupDir%" (echo !cError![!] Backup directory not found.!cReset! & pause & goto MainMenu)
echo. & echo  Available Data Backups in %BackupDir%:
set "backupCount=0"
for /f "delims=" %%B in ('dir "%BackupDir%\*_DATA_*" /b /ad') do (
    set /a backupCount+=1 & set "Backup_!backupCount!=%%B" & echo  [!backupCount!] %%B !cWarning!(Folder)!cReset!
)
for /f "delims=" %%B in ('dir "%BackupDir%\*.7z" /b') do (
    set /a backupCount+=1 & set "Backup_!backupCount!=%%B" & echo  [!backupCount!] %%B !cSuccess!(Compressed)!cReset!
)
if %backupCount% equ 0 (echo !cError![!] No data backups found.!cReset! & pause & goto MainMenu)
echo. & set /p "b_choice=!cChoice!Choose a backup number to restore: !cReset!"
if "%b_choice%"=="" goto MainMenu
if %b_choice% LEQ 0 if %b_choice% GTR %backupCount% goto ImportData
set "SelectedBackup=!Backup_%b_choice%!"
set "RestoreSourcePath=%BackupDir%\%SelectedBackup%"
set "TempRestorePath="

if /i "!SelectedBackup:~-3!"==".7z" (
    where 7z.exe >nul 2>nul
    if %errorlevel% neq 0 (
        echo. & echo !cError![!] 7-Zip is required to extract this archive. Please install it first.!cReset! & pause & goto MainMenu
    )
    set "TempRestorePath=%BackupDir%\TEMP_RESTORE_!random!"
    if exist "%TempRestorePath%" rd /s /q "%TempRestorePath%"
    md "%TempRestorePath%"
    echo !cWarning![*] Extracting archive... please wait.!cReset!
    7z.exe x "%RestoreSourcePath%" -o"%TempRestorePath%" > nul
    set "RestoreSourcePath=%TempRestorePath%"
)

for /f "tokens=1 delims=_" %%N in ("!SelectedBackup!") do set "ProfileName=%%N"
echo. & echo !cError!WARNING! This will overwrite current data.!cReset!
echo !cChoice!Are you sure you want to restore data for profile '!ProfileName!'? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto CleanupAndExit
set "inSection="
for /f "tokens=1,* delims==" %%a in ('type "%ConfigFile%"') do (
    if "!inSection!"=="true" ( if "%%a" LSS "[Profile:" (
        set "key=%%a" & set "path=%%b" & set "path=!path:%%USERPROFILE%%=%USERPROFILE%!"
        echo !cTitle!-------------------------------------------------------------------------------!cReset!
        echo  [*] Restoring '!key!' to '!path!'
        robocopy "!RestoreSourcePath!\!key!" "!path!" /E /R:2 /W:5 /NFL /NDL /NJH /NJS /nc /ns /np > nul
    ) else ( set "inSection=" ))
    if /i "%%a"=="[Profile:!ProfileName!]" set "inSection=true"
)
:CleanupAndExit
if defined TempRestorePath ( if exist "%TempRestorePath%" rd /s /q "%TempRestorePath%" )
echo !cTitle!-------------------------------------------------------------------------------!cReset!
echo !cSuccess![V] Import for backup '!SelectedBackup!' completed successfully.!cReset! & pause & goto MainMenu

:RegistryBackup
call :ShowHeader & echo  --- Backup (Export) Registry Keys ---
set /p "keyword=!cChoice!Enter a keyword to search for (e.g., Adobe, VideoLAN): !cReset!" & if not defined keyword goto MainMenu
if not exist "%BackupDir%" md "%BackupDir%"
echo !cWarning![*] Searching registry... This may take a moment.!cReset!
set "foundCount=0" & set "regHives=HKCU\Software HKLM\SOFTWARE HKLM\SOFTWARE\WOW6432Node"
for %%H in (%regHives%) do ( for /f "delims=" %%K in ('reg query "%%H" /s /f "%keyword%" /k') do (
    set /a foundCount+=1 & echo !cTitle!-------------------------------------------------------------------------------!cReset!
    echo !cWarning![!] Found potential key:!cReset! %%K
    echo !cChoice!==> Do you want to BACKUP (export) this key? [Y/N]!cReset! & choice /c YN /n
    if errorlevel 2 ( echo [-] Skipped. ) else (
        set "timestamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%" & set "timestamp=!timestamp: =0!"
        set "safeName=%%K" & set "safeName=!safeName:\=_!"
        set "RegBackupFile=%BackupDir%\REG_!safeName!_!timestamp!.reg"
        echo [*] Backing up to "!RegBackupFile!"...
        reg export "%%K" "!RegBackupFile!" /y
        echo !cSuccess![V] Backup successful.!cReset!
    )
))
echo !cTitle!-------------------------------------------------------------------------------!cReset!
echo !cSuccess![+] Search complete. Found and processed %foundCount% potential keys.!cReset! & pause & goto MainMenu

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

