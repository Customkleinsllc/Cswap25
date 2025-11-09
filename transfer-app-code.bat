@echo off
echo ========================================
echo   Transfer CSwap DEX Code to Server
echo ========================================
echo.

REM Create a temporary transfer directory
set TEMP_DIR=cswap-transfer-temp
if exist %TEMP_DIR% rmdir /s /q %TEMP_DIR%
mkdir %TEMP_DIR%

echo [1/5] Creating transfer archive...
cd "cswap-dex"

REM Copy backend files
echo Copying backend...
xcopy /E /I /Y backend ..\%TEMP_DIR%\backend

REM Copy frontend files
echo Copying frontend...
xcopy /E /I /Y frontend ..\%TEMP_DIR%\frontend

REM Copy config files
echo Copying configs...
copy /Y docker-compose.yml ..\%TEMP_DIR%\
copy /Y .env ..\%TEMP_DIR%\

cd ..

REM Copy deployment scripts
echo Copying deployment scripts...
copy /Y deploy.sh %TEMP_DIR%\
copy /Y setup-ssl.sh %TEMP_DIR%\
copy /Y health-check.sh %TEMP_DIR%\

REM Copy nginx config
mkdir %TEMP_DIR%\nginx
copy /Y cswap-dex\nginx\nginx.conf %TEMP_DIR%\nginx\

echo.
echo [2/5] Files prepared in %TEMP_DIR%
echo.
echo [3/5] You now need to transfer these files to the server.
echo.
echo ===== OPTION 1: Using WinSCP (Recommended) =====
echo 1. Download WinSCP: https://winscp.net/eng/download.php
echo 2. Connect to: cryptoswap.com
echo 3. Username: root
echo 4. Password: t9%%NnB3XpnF5s*KV
echo 5. Upload %TEMP_DIR%\* to /opt/cswap-dex/
echo.
echo ===== OPTION 2: Manual via Vultr Console =====
echo I'll generate individual file creation commands for you.
echo.
pause

echo.
echo Opening transfer directory...
explorer %TEMP_DIR%

echo.
echo ========================================
echo Transfer directory ready: %TEMP_DIR%
echo ========================================

