################################################################################
# Vultr Server Provisioning Script for CSwap DEX Exchange (PowerShell)
# 
# This script automates the creation of a Vultr server instance using the
# Vultr API v2. It provisions a server with the following specs:
# - Plan: vc2-2c-4gb (2 vCPU, 4GB RAM, 80GB SSD)
# - Region: Seattle (US West)
# - OS: Ubuntu 22.04 LTS
# 
# Prerequisites:
# - Set VULTR_API_KEY environment variable or pass as parameter
# - PowerShell 5.1 or later
#
# Usage:
#   .\vultr-provision.ps1 -ApiKey "your-api-key-here"
#   OR
#   $env:VULTR_API_KEY = "your-api-key-here"
#   .\vultr-provision.ps1
################################################################################

param(
    [string]$ApiKey = $env:VULTR_API_KEY
)

# Configuration
$VultrApiBase = "https://api.vultr.com/v2"
$PlanId = "vc2-2c-4gb"
$RegionId = "sea"  # Seattle, US West
$OsId = 1743       # Ubuntu 22.04 LTS x64
$Hostname = "cryptoswap-dex"
$Label = "CSwap DEX Exchange Server"
$EnableBackups = "enabled"
$EnableIPv6 = $true
$EnableDDoS = $false

# Helper Functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Invoke-VultrApi {
    param(
        [string]$Endpoint,
        [string]$Method = "GET",
        [hashtable]$Body = $null
    )
    
    $headers = @{
        "Authorization" = "Bearer $ApiKey"
        "Content-Type" = "application/json"
    }
    
    $uri = "$VultrApiBase$Endpoint"
    
    try {
        if ($Body -and ($Method -eq "POST" -or $Method -eq "PUT" -or $Method -eq "PATCH")) {
            $bodyJson = $Body | ConvertTo-Json -Depth 10
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body $bodyJson
        } else {
            $response = Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers
        }
        return $response
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorMessage = $_.Exception.Message
        Write-Error "API Error (HTTP $statusCode): $errorMessage"
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $responseBody = $reader.ReadToEnd()
            Write-Host $responseBody
        }
        throw
    }
}

# Check prerequisites
function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    if ([string]::IsNullOrEmpty($ApiKey)) {
        Write-Error "VULTR_API_KEY is not set"
        Write-Host "Please set it with: `$env:VULTR_API_KEY = 'your-api-key-here'"
        Write-Host "Or pass it as parameter: .\vultr-provision.ps1 -ApiKey 'your-api-key-here'"
        exit 1
    }
    
    # Check PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -lt 5) {
        Write-Error "PowerShell 5.1 or later is required. Current version: $psVersion"
        exit 1
    }
    
    Write-Success "All prerequisites met"
}

# Verify Vultr API key
function Test-ApiKey {
    Write-Info "Verifying Vultr API key..."
    
    try {
        $account = Invoke-VultrApi -Endpoint "/account"
        Write-Success "API key verified"
        return $true
    }
    catch {
        Write-Error "Invalid API key or API error"
        return $false
    }
}

# Check if plan is available
function Test-Plan {
    Write-Info "Verifying plan availability..."
    
    try {
        $plans = Invoke-VultrApi -Endpoint "/plans"
        $plan = $plans.plans | Where-Object { $_.id -eq $PlanId }
        
        if ($null -eq $plan) {
            Write-Error "Plan $PlanId not found"
            return $false
        }
        
        Write-Success "Plan $PlanId is available"
        return $true
    }
    catch {
        Write-Error "Failed to fetch plans"
        return $false
    }
}

# Check if region is available
function Test-Region {
    Write-Info "Verifying region availability..."
    
    try {
        $regions = Invoke-VultrApi -Endpoint "/regions"
        $region = $regions.regions | Where-Object { $_.id -eq $RegionId }
        
        if ($null -eq $region) {
            Write-Error "Region $RegionId not found"
            return $false
        }
        
        Write-Success "Region $RegionId (Seattle) is available"
        return $true
    }
    catch {
        Write-Error "Failed to fetch regions"
        return $false
    }
}

# Create firewall group
function New-FirewallGroup {
    Write-Info "Creating firewall group..."
    
    try {
        $firewallData = @{
            description = "CSwap DEX Firewall Rules"
        }
        
        $response = Invoke-VultrApi -Endpoint "/firewalls" -Method "POST" -Body $firewallData
        $firewallGroupId = $response.firewall_group.id
        
        Write-Success "Firewall group created: $firewallGroupId"
        
        # Add firewall rules
        Add-FirewallRules -FirewallGroupId $firewallGroupId
        
        return $firewallGroupId
    }
    catch {
        Write-Warning "Failed to create firewall group - may already exist"
        return $null
    }
}

# Add firewall rules
function Add-FirewallRules {
    param([string]$FirewallGroupId)
    
    Write-Info "Adding firewall rules..."
    
    $rules = @(
        @{ ip_type = "v4"; protocol = "tcp"; subnet = "0.0.0.0"; subnet_size = 0; port = "22"; notes = "SSH" },
        @{ ip_type = "v4"; protocol = "tcp"; subnet = "0.0.0.0"; subnet_size = 0; port = "80"; notes = "HTTP" },
        @{ ip_type = "v4"; protocol = "tcp"; subnet = "0.0.0.0"; subnet_size = 0; port = "443"; notes = "HTTPS" }
    )
    
    foreach ($rule in $rules) {
        try {
            Invoke-VultrApi -Endpoint "/firewalls/$FirewallGroupId/rules" -Method "POST" -Body $rule | Out-Null
        }
        catch {
            Write-Warning "Failed to add rule for port $($rule.port)"
        }
    }
    
    Write-Success "Firewall rules added"
}

# Create instance
function New-VultrInstance {
    Write-Info "Creating Vultr instance..."
    
    try {
        $instanceData = @{
            region = $RegionId
            plan = $PlanId
            os_id = $OsId
            label = $Label
            hostname = $Hostname
            enable_ipv6 = $EnableIPv6
            backups = $EnableBackups
            ddos_protection = $EnableDDoS
            tags = @("cswap", "dex", "production")
        }
        
        $response = Invoke-VultrApi -Endpoint "/instances" -Method "POST" -Body $instanceData
        $instanceId = $response.instance.id
        
        Write-Success "Instance created: $instanceId"
        return $instanceId
    }
    catch {
        Write-Error "Failed to create instance"
        throw
    }
}

# Wait for instance to be ready
function Wait-InstanceReady {
    param([string]$InstanceId)
    
    Write-Info "Waiting for instance to be ready (this may take 2-5 minutes)..."
    
    $maxAttempts = 60
    $attempt = 0
    
    while ($attempt -lt $maxAttempts) {
        try {
            $response = Invoke-VultrApi -Endpoint "/instances/$InstanceId"
            $status = $response.instance.status
            $serverStatus = $response.instance.server_status
            
            if ($status -eq "active" -and $serverStatus -eq "ok") {
                Write-Success "Instance is ready!"
                return $response.instance
            }
            
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 5
            $attempt++
        }
        catch {
            Write-Error "Failed to get instance status"
            throw
        }
    }
    
    Write-Error "Instance did not become ready in time"
    throw "Timeout waiting for instance"
}

# Print server information
function Show-ServerInfo {
    param($Instance)
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           CSwap DEX Server Successfully Provisioned           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Server Details:"
    Write-Host "  Instance ID: $($Instance.id)"
    Write-Host "  Label: $($Instance.label)"
    Write-Host "  Hostname: $($Instance.hostname)"
    Write-Host "  IP Address: $($Instance.main_ip)"
    Write-Host "  Default Password: $($Instance.default_password)"
    Write-Host ""
    Write-Host "SSH Connection:"
    Write-Host "  ssh root@$($Instance.main_ip)"
    Write-Host "  Password: $($Instance.default_password)"
    Write-Host ""
    Write-Host "Next Steps:"
    Write-Host "  1. Update DNS records for cryptoswap.com to point to $($Instance.main_ip)"
    Write-Host "     - A record: cryptoswap.com -> $($Instance.main_ip)"
    Write-Host "     - A record: www.cryptoswap.com -> $($Instance.main_ip)"
    Write-Host ""
    Write-Host "  2. SSH into the server and run the initialization script:"
    Write-Host "     ssh root@$($Instance.main_ip)"
    Write-Host ""
    Write-Host "  3. Transfer server-init.sh to the server:"
    Write-Host "     scp server-init.sh root@$($Instance.main_ip):/root/"
    Write-Host "     (Or use WinSCP/FileZilla on Windows)"
    Write-Host ""
    Write-Host "  4. Follow the deployment guide in VULTR_DEPLOYMENT.md"
    Write-Host ""
    
    # Save server info to file
    $Instance | ConvertTo-Json -Depth 10 | Out-File -FilePath "vultr-server-info.json" -Encoding UTF8
    Write-Success "Server information saved to vultr-server-info.json"
}

# Main execution
function Main {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        Vultr Server Provisioning for CSwap DEX Exchange       ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        Test-Prerequisites
        
        if (-not (Test-ApiKey)) {
            exit 1
        }
        
        if (-not (Test-Plan)) {
            exit 1
        }
        
        if (-not (Test-Region)) {
            exit 1
        }
        
        # Create firewall group (optional, may already exist)
        $firewallGroupId = New-FirewallGroup
        
        # Create instance
        $instanceId = New-VultrInstance
        
        # Wait for instance to be ready
        $instance = Wait-InstanceReady -InstanceId $instanceId
        
        # Print server information
        Show-ServerInfo -Instance $instance
        
        Write-Success "Provisioning complete!"
    }
    catch {
        Write-Error "Provisioning failed: $($_.Exception.Message)"
        exit 1
    }
}

# Run main function
Main

