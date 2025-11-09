# CSwap DEX - Windows Setup Guide

## Overview

This guide is specifically for Windows users deploying the CSwap DEX to Vultr. The main difference is that you'll use PowerShell scripts locally, while the server-side scripts remain as bash (since they run on Ubuntu).

## 📋 Prerequisites for Windows

### 1. Install Required Software

**PowerShell 5.1 or later** (usually pre-installed on Windows 10/11)
- Check version: Open PowerShell and run `$PSVersionTable.PSVersion`

**SSH Client** (built into Windows 10/11)
- Test: `ssh -V` in PowerShell or Command Prompt

**Git for Windows** (optional but recommended)
- Download: https://git-scm.com/download/win

**WinSCP or FileZilla** (for file transfers)
- WinSCP: https://winscp.net/
- FileZilla: https://filezilla-project.org/

### 2. Enable PowerShell Script Execution

Open PowerShell as Administrator and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

This allows running local PowerShell scripts.

## 🚀 Quick Start for Windows

### Step 1: Set Up Your Environment

```powershell
# Open PowerShell in the project directory
cd "C:\Users\CryptoSwap\Desktop\Cswap Web UNI"

# Set your Vultr API key
$env:VULTR_API_KEY = "JHCBIY55BPB77DPW675I3XCHWGTYFUSN4CBQ"
```

### Step 2: Provision the Server

```powershell
# Run the PowerShell provisioning script
.\vultr-provision.ps1
```

**Alternative with API key as parameter:**
```powershell
.\vultr-provision.ps1 -ApiKey "JHCBIY55BPB77DPW675I3XCHWGTYFUSN4CBQ"
```

**Output:** Server IP address and credentials saved to `vultr-server-info.json`

### Step 3: Configure DNS

Go to your domain registrar and add:
- **A Record**: `cryptoswap.com` → `YOUR_SERVER_IP`
- **A Record**: `www.cryptoswap.com` → `YOUR_SERVER_IP`

### Step 4: Transfer Files to Server

**Option A: Using SCP (Command Line)**
```powershell
# Transfer server initialization script
scp server-init.sh root@YOUR_SERVER_IP:/root/

# Transfer other server-side scripts
scp setup-ssl.sh root@YOUR_SERVER_IP:/root/
scp deploy.sh root@YOUR_SERVER_IP:/root/
scp health-check.sh root@YOUR_SERVER_IP:/root/
```

**Option B: Using WinSCP (GUI)**
1. Open WinSCP
2. Create new connection:
   - File protocol: SFTP
   - Host name: YOUR_SERVER_IP
   - Port: 22
   - User name: root
   - Password: (from provisioning output)
3. Connect and drag-drop files to `/root/`

**Option C: Using FileZilla**
1. Open FileZilla
2. File → Site Manager → New Site
3. Protocol: SFTP
4. Host: YOUR_SERVER_IP
5. User: root
6. Password: (from provisioning output)
7. Connect and upload files

### Step 5: Connect to Server via SSH

```powershell
# SSH into your server
ssh root@YOUR_SERVER_IP

# Enter the password when prompted (from provisioning output)
```

### Step 6: Initialize Server (on Ubuntu server)

Once connected via SSH:

```bash
# Make scripts executable
chmod +x server-init.sh
chmod +x setup-ssl.sh
chmod +x deploy.sh
chmod +x health-check.sh

# Run initialization
./server-init.sh
```

This will take 5-10 minutes to complete.

### Step 7: Setup SSL (on Ubuntu server)

```bash
# Still on the server via SSH
./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
```

### Step 8: Deploy Application (on Ubuntu server)

```bash
# Switch to application user
su - cswap
cd /opt/cswap-dex

# Clone your repository
git clone https://github.com/your-username/cswap-dex.git .

# Configure environment
cp .env.production .env
nano .env  # Update passwords and secrets

# Deploy
./deploy.sh
```

### Step 9: Verify

```bash
# Check health
./health-check.sh --verbose

# Test HTTPS
curl https://cryptoswap.com
```

## 💻 Windows-Specific Commands

### PowerShell Equivalents

| Linux/Bash           | Windows PowerShell                        |
| -------------------- | ----------------------------------------- |
| `ls -la`             | `Get-ChildItem` or `dir`                  |
| `cat file.txt`       | `Get-Content file.txt` or `type file.txt` |
| `grep "text" file`   | `Select-String "text" file`               |
| `pwd`                | `Get-Location` or `pwd`                   |
| `chmod +x script.sh` | N/A (not needed on Windows)               |

### File Paths

Windows uses backslashes in paths:
```powershell
cd "C:\Users\CryptoSwap\Desktop\Cswap Web UNI"
```

PowerShell also accepts forward slashes:
```powershell
cd "C:/Users/CryptoSwap/Desktop/Cswap Web UNI"
```

### Environment Variables

**Set temporarily (current session only):**
```powershell
$env:VULTR_API_KEY = "JHCBIY55BPB77DPW675I3XCHWGTYFUSN4CBQ"
```

**Set permanently (user level):**
```powershell
[System.Environment]::SetEnvironmentVariable("VULTR_API_KEY", "JHCBIY55BPB77DPW675I3XCHWGTYFUSN4CBQ", "User")
```

**View environment variable:**
```powershell
echo $env:VULTR_API_KEY
```

## 📝 Important Notes for Windows Users

### Line Endings
If you edit bash scripts on Windows, be careful about line endings:
- Windows uses CRLF (`\r\n`)
- Linux uses LF (`\n`)

**Solution:**
- Use Git for Windows with `core.autocrlf=true`
- Or use editors like VS Code, Notepad++, or Sublime Text with "Unix (LF)" line endings
- Or run `dos2unix` on the server after uploading

### SSH Key Setup (Optional but Recommended)

**Generate SSH key:**
```powershell
ssh-keygen -t ed25519 -C "admin@cryptoswap.com"
```

**Copy public key to server:**
```powershell
# Get your public key
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub

# SSH into server and add to authorized_keys
ssh root@YOUR_SERVER_IP
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Paste your public key and save
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### PowerShell Script Security

If you see an error like "cannot be loaded because running scripts is disabled":

```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🔧 Troubleshooting Windows-Specific Issues

### Issue: PowerShell Script Won't Run

**Error:** "File cannot be loaded because running scripts is disabled"

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: SSH Not Found

**Error:** "ssh is not recognized as an internal or external command"

**Solution:**
- Windows 10/11: SSH should be pre-installed. If not, install via Settings → Apps → Optional Features → Add OpenSSH Client
- Or use PuTTY: https://www.putty.org/

### Issue: SCP Not Working

**Solution:** Use WinSCP or FileZilla (GUI alternatives)

### Issue: Line Ending Problems

**Error:** Script fails with `^M` or syntax errors on server

**Solution:**
```bash
# On the server, convert line endings
dos2unix server-init.sh
dos2unix setup-ssl.sh
dos2unix deploy.sh
dos2unix health-check.sh
```

Or install dos2unix on server:
```bash
apt-get install dos2unix
```

### Issue: Path with Spaces

If your path has spaces, use quotes:
```powershell
cd "C:\Users\CryptoSwap\Desktop\Cswap Web UNI"
```

## 📁 File Organization for Windows

```
C:\Users\CryptoSwap\Desktop\Cswap Web UNI\
├── vultr-provision.ps1          # ← Run this locally on Windows
├── vultr-provision.sh            # (For Linux/Mac users)
├── server-init.sh                # ← Upload to server
├── setup-ssl.sh                  # ← Upload to server
├── deploy.sh                     # ← Upload to server
├── health-check.sh               # ← Upload to server
├── cswap-dex\
│   ├── docker-compose.yml
│   ├── .env.production
│   └── nginx\
│       └── nginx.conf
├── VULTR_DEPLOYMENT.md
├── WINDOWS_SETUP.md              # ← This file
└── vultr-server-info.json        # Generated after provisioning
```

## 🎯 Complete Windows Workflow

1. **Local (PowerShell):**
   ```powershell
   $env:VULTR_API_KEY = "your-key"
   .\vultr-provision.ps1
   ```

2. **Configure DNS** (browser/domain registrar)

3. **Transfer files** (WinSCP/FileZilla)

4. **Remote (SSH to Ubuntu server):**
   ```bash
   chmod +x *.sh
   ./server-init.sh
   ./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
   ```

5. **Deploy** (as cswap user on server):
   ```bash
   su - cswap
   cd /opt/cswap-dex
   git clone <repo> .
   cp .env.production .env
   nano .env
   ./deploy.sh
   ```

6. **Verify:**
   ```bash
   ./health-check.sh --verbose
   ```

## 📖 Additional Resources

- **PowerShell Documentation**: https://docs.microsoft.com/powershell/
- **Windows Terminal**: https://aka.ms/terminal (recommended)
- **VS Code**: https://code.visualstudio.com/ (excellent for editing)
- **WinSCP**: https://winscp.net/
- **PuTTY**: https://www.putty.org/

## ✅ Summary

- Use `vultr-provision.ps1` on Windows (instead of .sh version)
- Transfer server-side scripts using WinSCP/FileZilla or SCP
- All server-side operations are the same (they run on Ubuntu)
- Watch out for line ending issues when editing bash scripts on Windows

---

**Next Steps:** Follow [VULTR_DEPLOYMENT.md](VULTR_DEPLOYMENT.md) for complete deployment instructions (skip the bash-specific parts for local execution).

