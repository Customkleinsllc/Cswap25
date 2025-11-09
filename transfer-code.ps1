# Transfer Application Code to Server
# This creates a WinSCP script to transfer all files

$SERVER = "144.202.83.16"
$USER = "root"
$PASSWORD = "t9%NnB3XpnF5s*KV"
$LOCAL = "C:\Users\CryptoSwap\Desktop\Cswap Web UNI\cswap-dex"

Write-Host "Creating WinSCP transfer script..." -ForegroundColor Cyan

# Create WinSCP script
$script = @"
option batch abort
option confirm off
open sftp://${USER}:${PASSWORD}@${SERVER}/
cd /opt/cswap-dex

# Transfer backend
lcd "$LOCAL\backend"
cd /opt/cswap-dex/backend
put -delete *

# Transfer frontend  
lcd "$LOCAL\frontend"
cd /opt/cswap-dex/frontend
put -delete *

# Transfer config files
lcd "$LOCAL"
cd /opt/cswap-dex
put .env.production
put docker-compose.yml
put package.json

# Transfer nginx config
lcd "$LOCAL\nginx"
cd /opt/cswap-dex/nginx
put nginx.conf

close
exit
"@

$script | Out-File -FilePath "winscp-script.txt" -Encoding ASCII

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Transfer Script Created!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To transfer files, you have 2 options:" -ForegroundColor Yellow
Write-Host ""
Write-Host "OPTION 1: Use WinSCP (GUI - EASIEST)" -ForegroundColor Cyan
Write-Host "  1. Download WinSCP: https://winscp.net/" -ForegroundColor White
Write-Host "  2. Connect to: $SERVER" -ForegroundColor White
Write-Host "  3. User: $USER, Password: $PASSWORD" -ForegroundColor White
Write-Host "  4. Navigate to /opt/cswap-dex" -ForegroundColor White
Write-Host "  5. Drag and drop:" -ForegroundColor White
Write-Host "     - backend folder -> /opt/cswap-dex/backend" -ForegroundColor Gray
Write-Host "     - frontend folder -> /opt/cswap-dex/frontend" -ForegroundColor Gray
Write-Host "     - .env.production -> /opt/cswap-dex/" -ForegroundColor Gray
Write-Host "     - docker-compose.yml -> /opt/cswap-dex/" -ForegroundColor Gray
Write-Host ""
Write-Host "OPTION 2: Use tar + base64 (if WinSCP fails)" -ForegroundColor Cyan
Write-Host "  Run the next script I'll create..." -ForegroundColor White
Write-Host ""

# Try to open WinSCP
$winscpPath = "C:\Program Files (x86)\WinSCP\WinSCP.exe"
if (Test-Path $winscpPath) {
    Write-Host "Opening WinSCP..." -ForegroundColor Green
    & $winscpPath /script="winscp-script.txt"
} else {
    Write-Host "WinSCP not found at: $winscpPath" -ForegroundColor Yellow
    Write-Host "Download from: https://winscp.net/" -ForegroundColor Yellow
}

