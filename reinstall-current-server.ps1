# Reinstall Current Vultr Server (KEEPS SAME IP)
# Uses Vultr API to wipe and reinstall with new startup script

param(
    [string]$ApiKey = "JHCBIY55BPB77DPW675I3XCHWGTYFUSN4CBQ"
)

$ErrorActionPreference = "Stop"

# Current server details
$InstanceId = "812a1b72-a6c6-4ac2-a2c7-47b8f2c0d334"
$CurrentIP = "144.202.83.16"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CSwap DEX - Server Reinstall" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will:" -ForegroundColor Yellow
Write-Host "  ✓ KEEP the same IP: $CurrentIP" -ForegroundColor Green
Write-Host "  ✓ Wipe and reinstall Ubuntu 22.04" -ForegroundColor Yellow
Write-Host "  ✓ Apply improved startup script" -ForegroundColor Green
Write-Host "  ✓ Fix all directory and permission issues" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  WARNING: This will DELETE ALL data on the server!" -ForegroundColor Red
Write-Host ""
$Confirm = Read-Host "Type 'YES' to continue"

if ($Confirm -ne "YES") {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
}

# Read and encode startup script
Write-Host ""
Write-Host "📄 Reading startup script..." -ForegroundColor Cyan
$StartupScript = Get-Content -Path "server-init-v2.sh" -Raw
$StartupScriptBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($StartupScript))

# API Configuration
$Headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type" = "application/json"
}

# First, update user_data with new startup script
Write-Host "📤 Uploading new startup script..." -ForegroundColor Cyan
$UpdateBody = @{
    user_data = $StartupScriptBase64
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "https://api.vultr.com/v2/instances/$InstanceId" `
        -Method Patch `
        -Headers $Headers `
        -Body $UpdateBody | Out-Null
    
    Write-Host "✅ Startup script uploaded" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Warning: Could not update startup script" -ForegroundColor Yellow
    Write-Host "   Continuing with reinstall..." -ForegroundColor Yellow
}

# Reinstall the server
Write-Host ""
Write-Host "🔄 Reinstalling server..." -ForegroundColor Yellow

$ReinstallBody = @{
    hostname = "cryptoswap-dex"
} | ConvertTo-Json

try {
    $Response = Invoke-RestMethod -Uri "https://api.vultr.com/v2/instances/$InstanceId/reinstall" `
        -Method Post `
        -Headers $Headers `
        -Body $ReinstallBody
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ REINSTALL INITIATED!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Server Details:" -ForegroundColor Cyan
    Write-Host "  Instance ID: $InstanceId"
    Write-Host "  IP Address: $CurrentIP (UNCHANGED)" -ForegroundColor Green
    Write-Host "  Password: t9%NnB3XpnF5s*KV" -ForegroundColor Yellow
    Write-Host "  Hostname: cryptoswap-dex"
    Write-Host ""
    Write-Host "⏱️  Installation Progress:" -ForegroundColor Cyan
    Write-Host "  - Server is being wiped and reinstalled"
    Write-Host "  - Startup script will run automatically"
    Write-Host "  - Wait 5-10 minutes for completion"
    Write-Host ""
    Write-Host "✅ No DNS changes needed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "After 5-10 minutes:" -ForegroundColor Cyan
    Write-Host "  1. SSH: ssh root@$CurrentIP"
    Write-Host "  2. Password: t9%NnB3XpnF5s*KV"
    Write-Host "  3. cd /opt/cswap-dex"
    Write-Host "  4. docker compose up -d"
    Write-Host "  5. docker compose ps"
    Write-Host ""
    
    # Save info
    $InstallInfo = @{
        instance_id = $InstanceId
        ip_address = $CurrentIP
        password = "t9%NnB3XpnF5s*KV"
        hostname = "cryptoswap-dex"
        reinstall_time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        status = "reinstalling"
        estimated_completion = (Get-Date).AddMinutes(10).ToString("yyyy-MM-dd HH:mm:ss")
    }
    
    $InstallInfo | ConvertTo-Json | Out-File "server-reinstall-status.json"
    
    Write-Host "📊 Status saved to server-reinstall-status.json" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🎉 Reinstall in progress!" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        $ErrorJson = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host ""
        Write-Host "API Response:" -ForegroundColor Yellow
        Write-Host ($ErrorJson | ConvertTo-Json -Depth 3)
    }
    
    Write-Host ""
    Write-Host "Possible solutions:" -ForegroundColor Cyan
    Write-Host "  1. Check your API key is correct"
    Write-Host "  2. Ensure API key has write permissions"
    Write-Host "  3. Try again in a few minutes"
    
    exit 1
}

