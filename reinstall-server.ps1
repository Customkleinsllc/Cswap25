# Reinstall Vultr Server with Updated Startup Script
# This keeps the same IP address: 144.202.83.16

param(
    [string]$ApiKey = "YOUR_VULTR_API_KEY_HERE"
)

$ErrorActionPreference = "Stop"

# Server details
$InstanceId = "812a1b72-a6c6-4ac2-a2c7-47b8f2c0d334"
$ServerIP = "144.202.83.16"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "CSwap DEX Server Reinstallation" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will:"
Write-Host "  ✓ Keep the same IP: $ServerIP" -ForegroundColor Green
Write-Host "  ✓ Wipe and reinstall Ubuntu 22.04" -ForegroundColor Yellow
Write-Host "  ✓ Apply improved startup script" -ForegroundColor Green
Write-Host "  ✓ Set up everything correctly" -ForegroundColor Green
Write-Host ""

# Read startup script
$StartupScript = Get-Content -Path "server-init-v2.sh" -Raw

# Encode to base64
$StartupScriptBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($StartupScript))

# Prepare API request
$Headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type" = "application/json"
}

$Body = @{
    hostname = "cryptoswap-dex"
} | ConvertTo-Json

Write-Host "🔄 Reinstalling server..." -ForegroundColor Yellow
Write-Host ""

try {
    # Reinstall the instance
    $Response = Invoke-RestMethod -Uri "https://api.vultr.com/v2/instances/$InstanceId/reinstall" `
        -Method Post `
        -Headers $Headers `
        -Body $Body

    Write-Host "✅ Server reinstallation initiated!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Server Details:" -ForegroundColor Cyan
    Write-Host "  Instance ID: $InstanceId"
    Write-Host "  IP Address: $ServerIP" -ForegroundColor Green
    Write-Host "  Password: t9%NnB3XpnF5s*KV" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⏱️  Please wait 3-5 minutes for installation..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Wait for server to come online"
    Write-Host "  2. SSH: ssh root@$ServerIP"
    Write-Host "  3. cd /opt/cswap-dex"
    Write-Host "  4. docker compose up -d"
    Write-Host ""
    
    # Save updated info
    $ServerInfo = @{
        id = $InstanceId
        main_ip = $ServerIP
        default_password = "t9%NnB3XpnF5s*KV"
        hostname = "cryptoswap-dex"
        status = "reinstalling"
        reinstall_date = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
    
    $ServerInfo | ConvertTo-Json | Out-File "vultr-server-reinstall-info.json"
    Write-Host "✅ Server info saved to vultr-server-reinstall-info.json" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Setup initiated successfully!" -ForegroundColor Green

