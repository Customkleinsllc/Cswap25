# Script to help regain access to the server
$VULTR_API_KEY = "JHCBIY55BPB77DPW675I3XCHWGTYFUSN4CBQ"
$INSTANCE_ID = "812a1b72-a6c6-4ac2-a2c7-47b8f2c0d334"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Server Access Recovery" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Option 1: Use Vultr Web Console (RECOMMENDED)" -ForegroundColor Yellow
Write-Host "  1. Go to: https://my.vultr.com/subs/vps/novnc/?id=$INSTANCE_ID" -ForegroundColor White
Write-Host "  2. This opens a web-based console (no SSH needed)" -ForegroundColor White
Write-Host "  3. Login as root with password: t9%NnB3XpnF5s*KV" -ForegroundColor Green
Write-Host ""

Write-Host "Option 2: Reset Root Password via API" -ForegroundColor Yellow
Write-Host "  Running API command..." -ForegroundColor White

$headers = @{
    "Authorization" = "Bearer $VULTR_API_KEY"
    "Content-Type" = "application/json"
}

try {
    # Get instance info
    $response = Invoke-RestMethod -Uri "https://api.vultr.com/v2/instances/$INSTANCE_ID" -Headers $headers
    Write-Host "  Server Status: $($response.instance.status)" -ForegroundColor Green
    Write-Host "  Server State: $($response.instance.server_status)" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Opening Vultr console in browser..." -ForegroundColor Yellow
    Start-Process "https://my.vultr.com/subs/vps/novnc/?id=$INSTANCE_ID"
}
catch {
    Write-Host "  API Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Option 3: Try SSH with verbose output" -ForegroundColor Yellow
Write-Host "  Run this command to see what's blocking:" -ForegroundColor White
Write-Host "  ssh -v root@cryptoswap.com" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press any key to open Vultr Console..." -ForegroundColor Green
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Start-Process "https://my.vultr.com/subs/vps/novnc/?id=$INSTANCE_ID"

