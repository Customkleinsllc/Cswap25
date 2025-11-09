# Complete CSwap DEX Setup Script
# This script automates the entire deployment process

$SERVER = "root@cryptoswap.com"
$PASSWORD = "t9%NnB3XpnF5s*KV"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CSwap DEX Complete Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check server status
Write-Host "Checking server status..." -ForegroundColor Yellow
ssh $SERVER "echo 'Connected successfully' && docker --version && id cswap && ls -la /opt/cswap-dex/"

Write-Host ""
Write-Host "Setup will continue in SSH session..." -ForegroundColor Green
Write-Host "Password: $PASSWORD" -ForegroundColor Yellow
Write-Host ""

# Open interactive SSH session
ssh $SERVER


