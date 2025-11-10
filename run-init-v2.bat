@echo off
REM Apply new initialization script to current server
REM Keeps IP: 144.202.83.16

echo ========================================
echo CSwap DEX - Apply New Setup Script
echo ========================================
echo.
echo This will:
echo   - Upload server-init-v2.sh to current server
echo   - Run it to fix all issues
echo   - Keep current IP: 144.202.83.16
echo.
echo Password: t9%%NnB3XpnF5s*KV
echo.
pause

echo.
echo Uploading new initialization script...
scp server-init-v2.sh root@144.202.83.16:/root/

echo.
echo Running setup script...
ssh root@144.202.83.16 "chmod +x /root/server-init-v2.sh && /root/server-init-v2.sh"

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo   1. SSH: ssh root@144.202.83.16
echo   2. cd /opt/cswap-dex
echo   3. docker compose up -d
echo   4. docker compose ps
echo.
pause

