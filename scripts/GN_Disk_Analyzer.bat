@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                               GN Disk Analyzer
::                           Part of the GN Manager Suite
::                       (Final Corrected Version with CSV Export)
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
    cls & echo !cError! [!] ERROR: Administrator privileges are required for a full scan.!cReset!
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
echo [%DATE% %TIME%] [--- GN Disk Analyzer Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ██████╗ ██╗███████╗██╗  ██╗     █████╗  ███╗   ██╗!cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██╔══██╗██║██╔════╝██║  ██║    ██╔══██╗████╗  ██║!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ██║  ██║██║█████╗  ███████║    ███████║██╔██╗ ██║!cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ██║  ██║██║██╔══╝  ██╔══██║    ██╔══██║██║╚██╗██║!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ██████╔╝██║███████╗██║  ██║    ██║  ██║██║ ╚████║!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═══╝!cReset!
echo !cTitle!                              Disk Analyzer                                 !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo                  !cTitle!Disk Space Analysis and Reporting Tool!cReset!
echo.
echo    [1] Analyze a Specific Folder
echo    [2] Analyze a Drive
echo.
echo    [3] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-3): !cReset!"
if "%choice%"=="1" goto AnalyzeFolder
if "%choice%"=="2" goto AnalyzeDrive
if "%choice%"=="3" exit /b
goto MainMenu

:AnalyzeDrive
call :ShowHeader & echo  --- Select a Drive to Analyze ---
echo.
wmic logicaldisk get DeviceID, VolumeName, Size
echo.
set /p "driveLetter=!cChoice!Enter the drive letter to analyze (e.g., C): !cReset!"
if not defined driveLetter goto MainMenu
set "ScanPath=%driveLetter%:\"
goto ChooseReportType

:AnalyzeFolder
call :ShowHeader & echo  --- Analyze a Specific Folder ---
echo.
set /p "ScanPath=!cChoice!Enter the full path to the folder: !cReset!"
if not defined ScanPath goto MainMenu
if not exist "%ScanPath%" (
    echo !cError![!] The specified path does not exist.!cReset! & pause & goto MainMenu
)
goto ChooseReportType

:ChooseReportType
call :ShowHeader & echo --- Select Report Format ---
echo. & echo    [1] Plain Text Report (.txt) - Full analysis for quick viewing.
echo    [2] Spreadsheet Report (.csv) - Best for sorting and analysis in Excel.
echo. & set /p "reportChoice=!cChoice!Enter your choice (1-2): !cReset!"
if "%reportChoice%"=="1" goto RunAnalysisTXT
if "%reportChoice%"=="2" goto RunAnalysisCSV
goto ChooseReportType

:RunAnalysisPreamble
:: Safety Check
for %%F in ("%windir%", "%programfiles%", "%programfiles(x86)%") do (
    if /i "%ScanPath%"=="%%~F" (
        echo !cError![!] For safety, direct scanning of core system folders is not allowed.!cReset!
        echo Please scan a sub-folder instead, e.g., %programfiles%\SomeApp.
        pause & goto MainMenu
    )
)
set "timestamp=%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=!timestamp: =0!"
set "cleanPathName=!ScanPath::=!" & set "cleanPathName=!cleanPathName:\=_!"
call :ShowHeader
echo !cWarning!Starting analysis of: %ScanPath%!cReset!
echo This process can be very time-consuming for large drives or folders. Please be patient.
echo The report(s) will be generated in the current directory.
echo. & echo !cWarning!Scanning... (The window may appear frozen, this is normal)!cReset!
goto :eof

:RunAnalysisTXT
call :RunAnalysisPreamble
set "ReportFile=GN_Disk_Report_!cleanPathName!_!timestamp!.txt"
echo [%DATE% %TIME%] TXT Analysis started for path: "%ScanPath%". >> "%LogFile%"
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$path = '%ScanPath%';" ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "Add-Type -AssemblyName System.Windows.Forms;" ^
    "$ReportFile = '%ReportFile%';" ^
    "function Format-Size { param($bytes) if ($bytes -ge 1GB) { '{0:N2} GB' -f ($bytes / 1GB) } elseif ($bytes -ge 1MB) { '{0:N2} MB' -f ($bytes / 1MB) } elseif ($bytes -ge 1KB) { '{0:N2} KB' -f ($bytes / 1KB) } else { '{0} Bytes' -f $bytes } };" ^
    "Write-Output ('Analysis Report for: ' + $path) | Out-File -FilePath $ReportFile -Encoding utf8;" ^
    "Write-Output ('Report generated on: ' + (Get-Date)) | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "Write-Output ('======================================================================') | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "Write-Output '' | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "[System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::WaitCursor;" ^
    "$allItems = Get-ChildItem -Path $path -Recurse -Force;" ^
    "# --- Summary ---" ^
    "$totalSize = ($allItems | Where-Object { -not $_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum;" ^
    "$fileCount = ($allItems | Where-Object { -not $_.PSIsContainer }).Count;" ^
    "$folderCount = ($allItems | Where-Object { $_.PSIsContainer }).Count;" ^
    "Write-Output ('--- SCAN SUMMARY ---') | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "Write-Output ('Total Size   : ' + (Format-Size $totalSize)) | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "Write-Output ('Total Files  : ' + $fileCount) | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "Write-Output ('Total Folders: ' + $folderCount) | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "Write-Output '' | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "# --- Top 20 Largest Files ---" ^
    "Write-Output ('--- TOP 20 LARGEST FILES ---') | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "$allItems | Where-Object { -not $_.PSIsContainer } | Sort-Object -Property Length -Descending | Select-Object -First 20 | ForEach-Object { Write-Output (('{0,12} | {1}' -f (Format-Size $_.Length), $_.FullName)) } | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "Write-Output '' | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "# --- Folder Tree Analysis ---" ^
    "Write-Output ('--- FOLDER SIZE ANALYSIS (TOP-LEVEL) ---') | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "Get-ChildItem -Path $path -Directory | ForEach-Object { " ^
    "    $dirSize = (Get-ChildItem $_.FullName -Recurse -Force | Where-Object { -not $_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum;" ^
    "    [PSCustomObject]@{ Size = $dirSize; Name = $_.Name }" ^
    "} | Sort-Object Size -Descending | ForEach-Object { Write-Output (('{0,12} | {1}' -f (Format-Size $_.Size), $_.Name)) } | Out-File -FilePath $ReportFile -Append -Encoding utf8;" ^
    "[System.Windows.Forms.Cursor]::Current = [System.Windows.Forms.Cursors]::Default;"
echo. & echo !cSuccess![V] TXT report generated! Opening now...!cReset!
start "" "%ReportFile%"
echo. & pause & goto MainMenu

:RunAnalysisCSV
call :RunAnalysisPreamble
set "FoldersCsvFile=GN_Disk_Report_!cleanPathName!_!timestamp!_FOLDERS.csv"
set "FilesCsvFile=GN_Disk_Report_!cleanPathName!_!timestamp!_FILES.csv"
echo [%DATE% %TIME%] CSV Analysis started for path: "%ScanPath%". >> "%LogFile%"
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
    "$path = '%ScanPath%';" ^
    "$ErrorActionPreference = 'SilentlyContinue';" ^
    "Write-Host 'Analyzing... Step 1 of 2: Finding large files...';" ^
    "$allItems = Get-ChildItem -Path $path -Recurse -Force;" ^
    "$allItems | Where-Object { !$_.PSIsContainer } | Sort-Object -Property Length -Descending | Select-Object -First 50 | Select-Object FullName, @{Name='Size(MB)';Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime | Export-Csv -Path '%FilesCsvFile%' -NoTypeInformation -Encoding UTF8;" ^
    "Write-Host 'Analyzing... Step 2 of 2: Calculating folder sizes...';" ^
    "Get-ChildItem -Path $path -Directory | ForEach-Object { " ^
    "    $dir = $_;" ^
    "    $folderSize = ($allItems | Where-Object { $_.FullName.StartsWith($dir.FullName) -and !$_.PSIsContainer } | Measure-Object -Property Length -Sum).Sum;" ^
    "    [PSCustomObject]@{ FolderName = $_.Name; 'Size(GB)' = [math]::Round($folderSize / 1GB, 3); Path = $_.FullName }" ^
    "} | Sort-Object 'Size(GB)' -Descending | Export-Csv -Path '%FoldersCsvFile%' -NoTypeInformation -Encoding UTF8;"
echo. & echo !cSuccess![V] CSV reports generated successfully! Opening containing folder...!cReset!
start "" .
echo. & pause & goto MainMenu

:CreateDefaultConfig
(
    echo ; --- GN Manager Suite Configuration ---
) > "%ConfigFile%"
goto :eof
