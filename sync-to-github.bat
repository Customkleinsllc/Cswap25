@echo off
echo ========================================
echo Syncing Deployment Files to GitHub
echo ========================================
echo.

cd /d "%~dp0"

REM Check if we're in a git repo
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo Initializing git repository...
    git init
    git remote add origin https://github.com/Customkleinsllc/Cswap25.git
    git branch -M main
)

echo.
echo Adding deployment configuration files...

REM Add deployment files from cswap-dex directory
git add cswap-dex/.env.production
git add cswap-dex/docker-compose.yml
git add cswap-dex/nginx/nginx.conf
git add cswap-dex/package.json
git add cswap-dex/README.md
git add cswap-dex/SETUP.md

REM Add server setup scripts
git add server-init-enhanced.sh
git add setup-ssl.sh
git add deploy.sh
git add health-check.sh

REM Add documentation
git add VULTR_DEPLOYMENT.md
git add WINDOWS_SETUP.md
git add QUICK_START.md
git add DEPLOYMENT_SCRIPTS_README.md
git add IMPLEMENTATION_SUMMARY.md

echo.
echo Committing changes...
git commit -m "Add Vultr deployment configuration and automation scripts"

echo.
echo Pushing to GitHub...
git push -u origin main

if errorlevel 1 (
    echo.
    echo ========================================
    echo Push failed. You may need to:
    echo 1. Set up authentication (GitHub token or SSH key)
    echo 2. Force push if repo exists: git push -u origin main --force
    echo ========================================
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Files pushed to GitHub
echo ========================================
echo.
echo Next step: Update the server
echo Run: update-server.bat
echo.
pause

