# 🚀 CSwap DEX - Server Reinstall Guide

## Current Situation
Your server at **144.202.83.16** has build issues. Let's fix it with a clean reinstall!

---

## ✅ RECOMMENDED: Reinstall Current Server (Keep IP)

**This is the best option because:**
- ✅ Keeps IP: 144.202.83.16 (no DNS changes!)
- ✅ 100% clean installation
- ✅ Uses improved setup script
- ✅ Takes 5-10 minutes

### Steps:

#### 1. Get Your Vultr API Key
1. Go to: https://my.vultr.com/settings/#settingsapi
2. Create or copy your API key
3. Keep it ready!

#### 2. Edit the Script
Open `reinstall-current-server.ps1` and replace:
```powershell
[string]$ApiKey = "YOUR_VULTR_API_KEY_HERE"
```
With your actual API key.

#### 3. Run the Script
```powershell
.\reinstall-current-server.ps1
```

#### 4. Wait 5-10 Minutes
The script will:
- Upload the improved setup script
- Wipe the server
- Reinstall Ubuntu 22.04
- Run setup automatically

#### 5. Connect & Deploy
After 10 minutes:
```bash
ssh root@144.202.83.16
# Password: t9%NnB3XpnF5s*KV

cd /opt/cswap-dex
docker compose up -d
docker compose ps
```

**Done! Your site will be live at https://cryptoswap.com** ✨

---

## 🆕 Alternative: Create New Server (New IP)

**Only use this if reinstall fails!**

This will create a completely new server with a **new IP address**.

### Steps:

1. Edit `provision-new-server.ps1` - add your API key
2. Run: `.\provision-new-server.ps1`
3. **Update DNS** to point to new IP
4. Wait 5-10 minutes for DNS propagation

---

## 📋 What's Different in V2?

The improved setup script (`server-init-v2.sh`) fixes all the issues we encountered:

✅ **Fixed:**
- ❌ Nested directory structure → ✅ Flat structure
- ❌ SSH password disabled → ✅ Password auth enabled
- ❌ Missing dependencies → ✅ All deps included
- ❌ Permission errors → ✅ Proper permissions
- ❌ TypeScript build issues → ✅ Simplified build

✅ **Improvements:**
- Clones repo directly to `/opt/cswap-dex` (no nesting)
- Keeps SSH password auth enabled
- Installs all Node.js dependencies before Docker
- Creates optimized Dockerfiles
- Removes problematic docker-compose version attribute

---

## 🆘 Need Help?

If reinstall fails:
1. Check the error message
2. Verify your API key has write permissions
3. Try creating a new server instead
4. Contact me for assistance

---

## 📁 Files Overview

| File | Purpose |
|------|---------|
| `server-init-v2.sh` | Improved server setup script |
| `reinstall-current-server.ps1` | **USE THIS** - Reinstalls current server (keeps IP) |
| `provision-new-server.ps1` | Creates new server (new IP) |
| `REINSTALL_OPTIONS.md` | Detailed comparison of options |

---

## ⚡ Quick Start (TL;DR)

```powershell
# 1. Edit reinstall-current-server.ps1 with your API key
# 2. Run:
.\reinstall-current-server.ps1

# 3. Type: YES
# 4. Wait 10 minutes
# 5. SSH in and deploy:
ssh root@144.202.83.16
cd /opt/cswap-dex
docker compose up -d
```

**That's it!** 🎉

