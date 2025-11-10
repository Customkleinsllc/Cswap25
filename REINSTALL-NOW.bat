@echo off
REM Quick Reinstall - Keeps IP 144.202.83.16

echo ========================================
echo CSwap DEX Server Reinstall
echo ========================================
echo.
echo This will reinstall your server with:
echo   - Same IP: 144.202.83.16
echo   - Clean Ubuntu 22.04
echo   - Improved setup script
echo   - All fixes applied
echo.
echo ========================================
echo.

REM Check if API key is set in the PowerShell script
findstr /C:"YOUR_VULTR_API_KEY_HERE" reinstall-current-server.ps1 >nul
if %ERRORLEVEL% EQU 0 (
    echo ERROR: You need to add your Vultr API key first!
    echo.
    echo Steps:
    echo   1. Go to: https://my.vultr.com/settings/#settingsapi
    echo   2. Copy your API key
    echo   3. Edit reinstall-current-server.ps1
    echo   4. Replace YOUR_VULTR_API_KEY_HERE with your key
    echo   5. Run this batch file again
    echo.
    pause
    exit /b 1
)

echo Running reinstall script...
echo.
powershell.exe -ExecutionPolicy Bypass -File "reinstall-current-server.ps1"

echo.
echo ========================================
echo.
pause

