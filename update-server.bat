@echo off
echo ========================================
echo Updating CSwap DEX Server
echo ========================================
echo.

set SERVER=root@cryptoswap.com

echo Pulling latest code on server...
ssh %SERVER% "cd /opt/cswap-dex && git pull origin main"

if errorlevel 1 (
    echo.
    echo Pull failed. Trying to reset and pull...
    ssh %SERVER% "cd /opt/cswap-dex && git fetch origin && git reset --hard origin/main"
)

echo.
echo Setting permissions...
ssh %SERVER% "chown -R cswap:cswap /opt/cswap-dex"

echo.
echo ========================================
echo Server updated!
echo ========================================
echo.
echo Next steps:
echo 1. Configure environment: ssh %SERVER%
echo 2. Run: su - cswap
echo 3. Run: cd /opt/cswap-dex
echo 4. Run: cp .env.production .env
echo 5. Run: nano .env  (edit secrets)
echo 6. Exit to root and run: ./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
echo 7. Return to cswap and run: ./deploy.sh
echo.
pause

