@echo off
echo ========================================
echo   Opening GitHub Repository Settings
echo ========================================
echo.
echo This will open your GitHub repo settings page.
echo.
echo TO MAKE REPO PUBLIC:
echo   1. Scroll to bottom (Danger Zone)
echo   2. Click "Change repository visibility"
echo   3. Select "Make public"
echo   4. Confirm by typing repo name
echo.
echo Once the repo is public, you can pull code on the server!
echo.
pause

start https://github.com/Customkleinsllc/Cswap25/settings

echo.
echo ========================================
echo GitHub settings page opened in browser
echo ========================================
echo.
echo After making it public, run these commands in Vultr console:
echo.
echo   cd /opt/cswap-dex
echo   git pull origin master
echo   ls -la backend/src/
echo   ls -la frontend/src/
echo.
pause

