@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                              GN System Optimizer
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
echo [%DATE% %TIME%] [--- GN System Optimizer Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     ███████╗██╗   ██╗ █████╗  ████████╗██╗███████╗!cReset!
echo !cTitle!██╔════╝ ████╗  ██║     ██╔════╝╚██╗ ██╔╝██╔══██╗╚══██╔══╝██║██╔════╝!cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║     ███████╗ ╚████╔╝ ███████║   ██║   ██║█████╗  !cReset!
echo !cTitle!██║   ██║██║╚██╗██║     ╚════██║  ╚██╔╝  ██╔══██║   ██║   ██║██╔══╝  !cReset!
echo !cTitle!╚██████╔╝██║ ╚████║     ███████║   ██║   ██║  ██║   ██║   ██║███████╗!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝     ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝╚══════╝!cReset!
echo !cTitle!                              System Optimizer                              !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo                     !cTitle!System Optimization Toolkit!cReset!
echo.
echo    [1] RAM Optimizer (Free up memory)
echo    [2] Process Manager (View ^& Kill High-CPU Tasks)
echo    [3] Startup Program Manager
echo.
echo    [4] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-4): !cReset!"
if "%choice%"=="1" goto RAMOptimizer
if "%choice%"=="2" goto ProcessManager
if "%choice%"=="3" goto StartupManager
if "%choice%"=="4" exit /b
goto MainMenu

:RAMOptimizer
call :ShowHeader & echo  --- RAM Optimizer ---
echo. & echo This tool attempts to free up memory held by idle processes and clear system caches.
echo !cWarning!Its effect on modern Windows might be temporary, but it can be useful in low-memory situations.!cReset!
echo. & echo !cChoice!Are you sure you want to proceed? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto MainMenu
echo. & echo !cWarning![*] Optimizing memory... Please wait.!cReset!
powershell -Command "(Get-Process).WorkingSet | ForEach-Object { [System.GC]::Collect() }; Clear-DnsClientCache; (Get-WmiObject -Class Win32_OperatingSystem -EnableAllPrivileges).FreeVirtualMemory() | Out-Null"
echo !cSuccess![V] Memory optimization process completed.!cReset!
echo. & pause & goto MainMenu

:ProcessManager
:ProcessManagerLoop
call :ShowHeader & echo  --- Process Manager (High-CPU Tasks) ---
echo. & echo !cWarning!Listing top 15 processes sorted by CPU usage...!cReset! & echo.
powershell "Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 15 | Format-Table Id, ProcessName, @{Name='CPU(s)'; Expression={'{0:N2}' -f $_.CPU}}, @{Name='Memory(MB)';Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}"
echo. & echo !cTitle!-------------------------------------------------------------------------------!cReset!
echo Enter a Process ID (PID) from the list to terminate it.
set /p "procID=!cChoice!Enter PID (or type 'R' to Refresh, 'X' to Exit): !cReset!"
if /i "%procID%"=="X" goto MainMenu
if /i "%procID%"=="R" goto ProcessManagerLoop
if not defined procID goto ProcessManagerLoop
echo. & echo !cError!WARNING: Forcefully terminating a process can cause data loss or system instability.!cReset!
echo !cChoice!Are you sure you want to terminate process with PID %procID%? [Y/N]!cReset! & choice /c YN /n
if errorlevel 2 goto ProcessManagerLoop
taskkill /F /PID %procID%
echo. & echo !cWarning!Attempting to refresh list in 3 seconds...!cReset! & timeout /t 3 >nul
goto ProcessManagerLoop

:StartupManager
call :ShowHeader & echo  --- Startup Program Manager --- & echo.
echo !cWarning!Listing startup items from common locations...!cReset! & echo.
wmic startup get Caption, Command, Location, User
echo. & echo !cTitle!-------------------------------------------------------------------------------!cReset!
echo The list above shows programs that run on startup. To manage them,
echo use the quick access shortcuts below to open the official Windows tools.
echo. & echo    [1] Open current User's Startup Folder
echo    [2] Open All Users' Startup Folder
echo    [3] Open Task Manager (Startup Tab)
echo. & echo    [4] Back to Main Menu
echo.
set /p "sm_choice=!cChoice!Enter your choice (1-4): !cReset!"
if "%sm_choice%"=="1" start "" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
if "%sm_choice%"=="2" start "" "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Startup"
if "%sm_choice%"=="3" taskmgr /0 /startup
if "%sm_choice%"=="4" goto MainMenu
goto StartupManager

:CreateDefaultConfig
(
    echo ; --- GN Manager Suite Configuration ---
) > "%ConfigFile%"
goto :eof
