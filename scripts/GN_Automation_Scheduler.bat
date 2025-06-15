@echo off
setlocal enabledelayedexpansion

:: =================================================================================
::                         GN Automation Scheduler
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
echo [%DATE% %TIME%] [--- GN Automation Scheduler Started ---] >> "%LogFile%"
goto MainMenu
:: --- End of Core ---

:ShowHeader
cls & echo.
echo !cTitle! ██████╗ ███╗   ██╗     █████╗ ██╗   ██╗ ██████╗ ███╗   ██╗██╗ ██████╗ !cReset!
echo !cTitle!██╔════╝ ████╗  ██║    ██╔══██╗██║   ██║██╔═══██╗████╗  ██║██║██╔════╝ !cReset!
echo !cTitle!██║  ███╗██╔██╗ ██║    ███████║██║   ██║██║   ██║██╔██╗ ██║██║██║  ███╗!cReset!
echo !cTitle!██║   ██║██║╚██╗██║    ██╔══██║██║   ██║██║   ██║██║╚██╗██║██║██║   ██║!cReset!
echo !cTitle!╚██████╔╝██║ ╚████║    ██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║██║╚██████╔╝!cReset!
echo !cTitle! ╚═════╝ ╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝ ╚═════╝ !cReset!
echo !cTitle!                           Automation Scheduler                           !cReset!
echo !cTitle!===============================================================================!cReset!
echo !cWarning! Author: GeekNeuron                                Project: %cSuccess%https://github.com/GeekNeuron/GN-Manager%cReset!
echo !cTitle!===============================================================================!cReset!
echo. & goto :eof

:MainMenu
call :ShowHeader
echo                   !cTitle!Windows Task Scheduler for GN Manager Suite!cReset!
echo.
echo    [1] Create a New Scheduled Task
echo    [2] List All GN Manager Scheduled Tasks
echo    [3] Delete a Scheduled Task
echo.
echo    [4] Exit
echo.
set /p "choice=!cChoice!Enter your choice (1-4): !cReset!"
if "%choice%"=="1" goto CreateTask
if "%choice%"=="2" goto ListTasks
if "%choice%"=="3" goto DeleteTask
if "%choice%"=="4" exit /b
goto MainMenu

:ListTasks
call :ShowHeader & echo  --- GN Manager Scheduled Tasks --- & echo.
schtasks /query /fo LIST | find "GN_"
echo. & pause & goto MainMenu

:DeleteTask
call :ShowHeader & echo  --- Delete a Scheduled Task --- & echo.
schtasks /query /fo TABLE | find "GN_"
echo.
set /p "taskName=!cChoice!Enter the full Task Name to delete: !cReset!"
if not defined taskName goto MainMenu
echo. & echo !cError!Are you sure you want to delete the task '%taskName%'? [Y/N]!cReset!
choice /c YN /n & if errorlevel 2 goto MainMenu
schtasks /delete /tn "%taskName%" /f
echo. & pause & goto MainMenu

:CreateTask
call :ShowHeader & echo  --- Create a New Scheduled Task Wizard --- & echo.
:: Step 1: Task Name
set /p "taskName=!cChoice!Enter a name for the task (e.g., GN_Daily_Cleanup): !cReset!"
if not defined taskName goto MainMenu
if /i "%taskName:~0,3%" neq "GN_" set "taskName=GN_%taskName%"

:: Step 2: Choose Script
call :ShowHeader & echo  --- Step 2: Choose a script to run --- & echo.
set "scriptCount=0"
for %%F in (GN_*.bat) do (
    if /i "%%F" neq "%~nx0" (
        set /a scriptCount+=1
        set "Script_!scriptCount!=%%F"
        echo  [!scriptCount!] %%F
    )
)
echo. & set /p "scriptChoice=!cChoice!Enter the number of the script: !cReset!"
set "scriptToRun=!Script_%scriptChoice%!"
set "scriptPath=%cd%\%scriptToRun%"

:: Step 3: Choose Schedule
call :ShowHeader & echo  --- Step 3: Choose a schedule --- & echo.
echo  [1] Daily
echo  [2] Weekly
echo  [3] On Logon
set /p "schedChoice=!cChoice!Enter schedule type (1-3): !cReset!"
if "%schedChoice%"=="1" set "schedule=DAILY"
if "%schedChoice%"=="2" set "schedule=WEEKLY"
if "%schedChoice%"=="3" set "schedule=ONLOGON"

:: Step 4: Choose Time
set "timeParam="
if /i "%schedule%"=="DAILY" (
    call :ShowHeader & echo  --- Step 4: Choose a time (24-hour format) --- & echo.
    set /p "runTime=!cChoice!Enter time (e.g., 23:00 for 11 PM): !cReset!"
    set "timeParam=/st %runTime%"
)
if /i "%schedule%"=="WEEKLY" (
    call :ShowHeader & echo  --- Step 4: Choose a time (24-hour format) --- & echo.
    set /p "runTime=!cChoice!Enter time (e.g., 23:00 for 11 PM): !cReset!"
    set "timeParam=/st %runTime%"
)

:: Step 5: Create Task
echo !cWarning![*] Creating scheduled task...!cReset!
schtasks /create /tn "%taskName%" /tr "\"%scriptPath%\"" /sc %schedule% %timeParam% /rl HIGHEST /f
echo. & echo !cSuccess![V] Task '%taskName%' created successfully.!cReset!
echo. & pause & goto MainMenu
