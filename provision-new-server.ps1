# Provision Brand New Vultr Server for CSwap DEX
# This will create a new instance with a NEW IP address

param(
    [string]$ApiKey = "YOUR_VULTR_API_KEY_HERE"
)

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "CSwap DEX - New Server Provisioning" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  This will create a NEW server with a NEW IP" -ForegroundColor Yellow
Write-Host "    You will need to update DNS after completion" -ForegroundColor Yellow
Write-Host ""

# Read and encode startup script
$StartupScript = Get-Content -Path "server-init-v2.sh" -Raw
$StartupScriptBase64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($StartupScript))

# API Configuration
$Headers = @{
    "Authorization" = "Bearer $ApiKey"
    "Content-Type" = "application/json"
}

$Body = @{
    region = "sea"  # Seattle (US West)
    plan = "vc2-2c-4gb"  # 2 vCPU, 4GB RAM, 80GB SSD
    os_id = 1743  # Ubuntu 22.04 x64
    label = "CSwap DEX Exchange Server V2"
    hostname = "cryptoswap-dex"
    tags = @("cswap", "dex", "production", "v2")
    user_data = $StartupScriptBase64
    enable_ipv6 = $true
    backups = "enabled"
} | ConvertTo-Json

Write-Host "🚀 Creating new server..." -ForegroundColor Yellow
Write-Host ""

try {
    $Response = Invoke-RestMethod -Uri "https://api.vultr.com/v2/instances" `
        -Method Post `
        -Headers $Headers `
        -Body $Body

    $InstanceId = $Response.instance.id
    $NewIP = $Response.instance.main_ip
    
    Write-Host "✅ Server created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "New Server Details:" -ForegroundColor Cyan
    Write-Host "  Instance ID: $InstanceId"
    Write-Host "  Region: Seattle (US West)"
    Write-Host "  Plan: 2 vCPU, 4GB RAM, 80GB SSD"
    Write-Host ""
    Write-Host "⏱️  Waiting for IP assignment..." -ForegroundColor Yellow
    
    # Poll for IP address
    $MaxAttempts = 30
    $Attempt = 0
    
    while ($Attempt -lt $MaxAttempts) {
        Start-Sleep -Seconds 5
        $Attempt++
        
        try {
            $ServerInfo = Invoke-RestMethod -Uri "https://api.vultr.com/v2/instances/$InstanceId" `
                -Method Get `
                -Headers $Headers
            
            if ($ServerInfo.instance.main_ip -and $ServerInfo.instance.main_ip -ne "0.0.0.0") {
                $NewIP = $ServerInfo.instance.main_ip
                $Password = $ServerInfo.instance.default_password
                break
            }
        } catch {
            # Continue polling
        }
        
        Write-Host "." -NoNewline
    }
    
    Write-Host ""
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "🎉 SERVER READY!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Connection Details:" -ForegroundColor Cyan
    Write-Host "  NEW IP: $NewIP" -ForegroundColor Yellow
    Write-Host "  Password: $Password" -ForegroundColor Yellow
    Write-Host "  Username: root"
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Update DNS" -ForegroundColor Yellow
    Write-Host "  1. Go to your DNS provider"
    Write-Host "  2. Update A record for cryptoswap.com"
    Write-Host "  3. Change from: 144.202.83.16"
    Write-Host "  4. Change to:   $NewIP" -ForegroundColor Green
    Write-Host ""
    Write-Host "After DNS update (5-10 min):" -ForegroundColor Cyan
    Write-Host "  ssh root@$NewIP"
    Write-Host "  cd /opt/cswap-dex"
    Write-Host "  docker compose ps"
    Write-Host ""
    
    # Save server info
    $ServerData = @{
        id = $InstanceId
        main_ip = $NewIP
        default_password = $Password
        hostname = "cryptoswap-dex"
        region = "Seattle (US West)"
        plan = "2 vCPU, 4GB RAM"
        created = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        old_ip = "144.202.83.16"
        dns_update_required = $true
    }
    
    $ServerData | ConvertTo-Json | Out-File "vultr-server-NEW-info.json"
    Write-Host "✅ Server info saved to vultr-server-NEW-info.json" -ForegroundColor Green
    
    # Open DNS instructions
    Write-Host ""
    Write-Host "Opening DNS update instructions..." -ForegroundColor Yellow
    $DnsInstructions = @"
========================================
DNS UPDATE REQUIRED
========================================

OLD IP: 144.202.83.16
NEW IP: $NewIP

Steps:
1. Log into your DNS provider (Cloudflare/GoDaddy/etc)
2. Find the A record for: cryptoswap.com
3. Change the IP from 144.202.83.16 to $NewIP
4. Save and wait 5-10 minutes for propagation

After DNS propagates:
- Test: ping cryptoswap.com
- Should resolve to: $NewIP

Then SSH in:
ssh root@$NewIP
Password: $Password

cd /opt/cswap-dex
docker compose ps

Done!
"@
    
    $DnsInstructions | Out-File "DNS_UPDATE_INSTRUCTIONS.txt"
    notepad "DNS_UPDATE_INSTRUCTIONS.txt"
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    if ($_.ErrorDetails.Message) {
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    exit 1
}

Write-Host "🎉 Provisioning complete!" -ForegroundColor Green

