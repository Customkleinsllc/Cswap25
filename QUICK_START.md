# CSwap DEX Vultr Deployment - Quick Start Guide

> **Windows Users:** See [WINDOWS_SETUP.md](WINDOWS_SETUP.md) for Windows-specific instructions using PowerShell.

## 🚀 5-Minute Setup

### Prerequisites

**Linux/Mac:**
```bash
# Install required tools
sudo apt-get install -y curl jq git

# Set up permissions
chmod +x setup-permissions.sh
./setup-permissions.sh
```

**Windows:**
```powershell
# Use PowerShell - see WINDOWS_SETUP.md for full details
$env:VULTR_API_KEY = "your-api-key"
.\vultr-provision.ps1
```

### Step 1: Provision Server (2 min)

**Linux/Mac:**
```bash
export VULTR_API_KEY="your-vultr-api-key-here"
./vultr-provision.sh
```

**Windows (PowerShell):**
```powershell
$env:VULTR_API_KEY = "your-vultr-api-key-here"
.\vultr-provision.ps1
```

**Output:** Server IP address (e.g., 123.45.67.89)

### Step 2: Configure DNS (1 min)
Go to your domain registrar and add:
- A Record: `cryptoswap.com` → `123.45.67.89`
- A Record: `www.cryptoswap.com` → `123.45.67.89`

### Step 3: Transfer Files & Initialize Server (10 min)

**Transfer files to server:**
- **Linux/Mac:** `scp server-init.sh root@123.45.67.89:/root/`
- **Windows:** Use WinSCP or FileZilla (see WINDOWS_SETUP.md)

**Then SSH and initialize:**
```bash
# SSH into server (works on all platforms)
ssh root@123.45.67.89

# Make executable and run
chmod +x server-init.sh
./server-init.sh
```

### Step 4: Setup SSL (2 min)
```bash
# On the server (as root)
./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
```

### Step 5: Deploy Application (5 min)
```bash
# Switch to app user
su - cswap
cd /opt/cswap-dex

# Clone your repo
git clone https://github.com/your-username/cswap-dex.git .

# Configure environment
cp .env.production .env
nano .env  # Update passwords and secrets

# Deploy
./deploy.sh
```

### Step 6: Verify (1 min)
```bash
# Check health
./health-check.sh --verbose

# Test HTTPS
curl https://cryptoswap.com
```

## ✅ Done!

Your CSwap DEX is now live at **https://cryptoswap.com**

## 📖 Full Documentation

For detailed instructions, see:
- **[VULTR_DEPLOYMENT.md](VULTR_DEPLOYMENT.md)** - Complete guide
- **[DEPLOYMENT_SCRIPTS_README.md](DEPLOYMENT_SCRIPTS_README.md)** - Scripts reference
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - What was built

## 🆘 Common Issues

**Issue:** DNS not resolving
```bash
# Check propagation
dig cryptoswap.com +short
# Wait 5-30 minutes for propagation
```

**Issue:** SSL certificate failed
```bash
# Verify DNS first, then retry
./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
```

**Issue:** Containers not starting
```bash
# Check logs
docker compose logs
# Rebuild
docker compose up -d --build
```

## 📞 Need Help?

Check the troubleshooting section in [VULTR_DEPLOYMENT.md](VULTR_DEPLOYMENT.md)

