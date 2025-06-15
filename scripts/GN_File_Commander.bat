@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                             GN File Commander
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
echo [%DATE% %TIME%] [--- GN File Commander Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ███████╗██╗██╗     ██████╗ ███╗   ███╗██████╗ !cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██╔════╝██║██║     ██╔══██╗████╗ ████║██╔══██╗!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     █████╗  ██║██║     ██║  ██║██╔████╔██║██████╔╝!cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██╔══╝  ██║██║     ██║  ██║██║╚██╔╝██║██╔══██╗!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ███████╗██║███████╗██████╔╝██║ ╚═╝ ██║██║  ██║!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚══════╝╚═╝╚══════╝╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝!cReset!
echo !cTitle!                               File Commander                              !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo                   !cTitle!Advanced File Operations Toolkit!cReset!
echo.
echo    [1] Bulk Rename Files
echo    [2] Find Duplicate Files
echo    [3] Auto-Organize Folder by Type
echo.
echo    [4] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-4): !cReset!"
if "%choice%"=="1" goto BulkRename
if "%choice%"=="2" goto FindDuplicates
if "%choice%"=="3" goto OrganizeFolder
if "%choice%"=="4" exit /b
goto MainMenu

:BulkRename
call :ShowHeader & echo  --- Bulk Rename Files ---
set /p "folder=!cChoice!Enter the path to the folder: !cReset!" & if not defined folder goto MainMenu
set /p "search=!cChoice!Enter the text to find in filenames: !cReset!"
set /p "replace=!cChoice!Enter the text to replace it with: !cReset!"
echo. & echo !cWarning!PREVIEW of changes:!cReset!
powershell -Command "Get-ChildItem -Path '%folder%' | Where-Object { $_.Name -like '*%search%*' } | ForEach-Object { Write-Host ('FROM: ' + $_.Name); Write-Host ('TO:   ' + ($_.Name -replace '%search%','%replace%')); Write-Host '' }"
echo. & echo !cError!Are you sure you want to perform this rename operation? [Y/N]!cReset!
choice /c YN /n & if errorlevel 2 goto MainMenu
powershell -Command "Get-ChildItem -Path '%folder%' | Where-Object { $_.Name -like '*%search%*' } | Rename-Item -NewName { $_.Name -replace '%search%','%replace%' }"
echo !cSuccess![V] Bulk rename operation completed.!cReset! & echo. & pause & goto MainMenu

:FindDuplicates
call :ShowHeader & echo  --- Find Duplicate Files ---
set /p "folder=!cChoice!Enter the path to the folder to scan: !cReset!" & if not defined folder goto MainMenu
echo !cWarning![*] Scanning for duplicates... This can be very slow for large folders.!cReset!
powershell -Command ^
    "$hashes = @{};" ^
    "Get-ChildItem -Path '%folder%' -Recurse -File | ForEach-Object {" ^
    "   $hash = (Get-FileHash $_.FullName -Algorithm MD5).Hash;" ^
    "   if ($hashes.ContainsKey($hash)) { $hashes[$hash] += @($_.FullName) } else { $hashes[$hash] = @($_.FullName) }" ^
    "};" ^
    "$duplicates = $hashes.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 };" ^
    "if ($duplicates) {" ^
    "   $duplicates | ForEach-Object { Write-Host '--- Duplicate Set ---'; $_.Value | ForEach-Object { Write-Host $_ } }" ^
    "} else { Write-Host 'No duplicate files found.' }"
echo. & echo !cSuccess![V] Duplicate scan finished.!cReset! & pause & goto MainMenu

:OrganizeFolder
call :ShowHeader & echo  --- Auto-Organize Folder by File Type ---
set /p "folder=!cChoice!Enter the path to the folder to organize (e.g., Downloads): !cReset!" & if not defined folder goto MainMenu
echo. & echo !cError!This will move all files in '%folder%' into subfolders based on their extension.!cReset!
echo !cChoice!Are you sure you want to continue? [Y/N]!cReset! & choice /c YN /n & if errorlevel 2 goto MainMenu
echo !cWarning![*] Organizing files...!cReset!
powershell -Command ^
    "Get-ChildItem -Path '%folder%' -File | ForEach-Object {" ^
    "   $ext = $_.Extension.TrimStart('.');" ^
    "   if ($ext) {" ^
    "       $destDir = Join-Path $_.DirectoryName $ext;" ^
    "       New-Item -ItemType Directory -Path $destDir -ErrorAction SilentlyContinue;" ^
    "       Move-Item $_.FullName -Destination $destDir;" ^
    "       Write-Host ('Moved ' + $_.Name + ' to \' + $ext + '\ folder.')" ^
    "   }" ^
    "}"
echo. & echo !cSuccess![V] Folder organization complete.!cReset! & pause & goto MainMenu
