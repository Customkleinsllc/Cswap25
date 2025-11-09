@echo off
echo ========================================
echo Vultr Server Provisioning
echo ========================================
echo.

REM Set API key
set VULTR_API_KEY=JHCBIY55BPB77DPW675I3XCHWGTYFUSN4CBQ

REM Run PowerShell script with full path
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { $env:VULTR_API_KEY='%VULTR_API_KEY%'; & '%~dp0vultr-provision.ps1' }"

echo.
echo Press any key to exit...
pause > nul

