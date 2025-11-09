# Automated Deployment Script for CSwap DEX
# This script transfers files and sets up the server automatically

$SERVER = "cryptoswap.com"
$USER = "root"
$PASSWORD = "t9%NnB3XpnF5s*KV"
$LOCAL_PATH = "C:\Users\CryptoSwap\Desktop\Cswap Web UNI\cswap-dex"
$REMOTE_PATH = "/opt/cswap-dex"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CSwap DEX Automated Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create a temporary script for remote execution
$remoteScript = @'
#!/bin/bash
set -e

echo "=== Creating directory structure ==="
mkdir -p /opt/cswap-dex/backend
mkdir -p /opt/cswap-dex/frontend
mkdir -p /opt/cswap-dex/nginx
mkdir -p /opt/cswap-dex/logs
mkdir -p /opt/cswap-dex/backups

echo "=== Setting ownership ==="
chown -R cswap:cswap /opt/cswap-dex 2>/dev/null || echo "cswap user not yet created"

echo "=== Checking Docker ==="
docker --version || echo "Docker not installed"

echo "=== Current directory contents ==="
ls -la /opt/cswap-dex/

echo "=== Setup complete! ==="
'@

# Save script locally
$remoteScript | Out-File -FilePath ".\remote-setup.sh" -Encoding ASCII -NoNewline

Write-Host "Remote setup script created" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "MANUAL STEPS REQUIRED:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open WinSCP and connect to:" -ForegroundColor White
Write-Host "   Host: $SERVER" -ForegroundColor Cyan
Write-Host "   User: $USER" -ForegroundColor Cyan
Write-Host "   Pass: $PASSWORD" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Upload these files/folders to /opt/cswap-dex/:" -ForegroundColor White
Write-Host "   - $LOCAL_PATH\backend\" -ForegroundColor Cyan
Write-Host "   - $LOCAL_PATH\frontend\" -ForegroundColor Cyan
Write-Host "   - $LOCAL_PATH\nginx\" -ForegroundColor Cyan
Write-Host "   - $LOCAL_PATH\.env.production" -ForegroundColor Cyan
Write-Host "   - $LOCAL_PATH\docker-compose.yml" -ForegroundColor Cyan
Write-Host "   - $LOCAL_PATH\package.json" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Upload deployment scripts to /root/:" -ForegroundColor White
Write-Host "   - .\deploy.sh" -ForegroundColor Cyan
Write-Host "   - .\setup-ssl.sh" -ForegroundColor Cyan
Write-Host "   - .\health-check.sh" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. SSH to server and run:" -ForegroundColor White
Write-Host "   ssh $USER@$SERVER" -ForegroundColor Cyan
Write-Host "   chmod +x /root/*.sh" -ForegroundColor Cyan
Write-Host "   chown -R cswap:cswap /opt/cswap-dex" -ForegroundColor Cyan
Write-Host ""
Write-Host "OR use this one-liner to test connection:" -ForegroundColor Yellow
Write-Host 'ssh root@cryptoswap.com "ls -la /opt/cswap-dex && docker --version"' -ForegroundColor Cyan
Write-Host ""
Write-Host "Password: $PASSWORD" -ForegroundColor Green
Write-Host ""

# Try to open WinSCP if installed
$winscpPath = "C:\Program Files (x86)\WinSCP\WinSCP.exe"
if (Test-Path $winscpPath) {
    Write-Host "Opening WinSCP..." -ForegroundColor Green
    & $winscpPath
}
else {
    Write-Host "WinSCP not found. Download from: https://winscp.net/" -ForegroundColor Yellow
}


