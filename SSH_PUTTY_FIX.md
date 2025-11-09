# SSH/PuTTY Connection Issue - Diagnosis & Fix

## 🚨 Problem Identified

**Your SSH password authentication is DISABLED** by the `server-init-enhanced.sh` script.

### Root Cause
Line 62-65 in `server-init-enhanced.sh`:
```bash
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
```

This disabled password authentication entirely, which is why:
- ✗ PuTTY can't connect (password auth disabled)
- ✗ `ssh root@cryptoswap.com` fails with "Too many authentication failures"
- ✓ VNC console works (direct console access, bypasses SSH)

## ✅ Solution Options

### Option 1: Re-enable SSH Password Authentication (Quick Fix)

**In VNC Console (with Caps Lock ON for lowercase), run:**

```bash
cd /opt/cswap-dex
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
echo "SSH password authentication re-enabled!"
```

**Then test from Windows:**
```powershell
ssh root@cryptoswap.com
```

---

### Option 2: Set Up SSH Key Authentication (Recommended for Production)

**On Windows (PowerShell):**
```powershell
# Generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "cryptoswap-server"

# Copy public key to server
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh root@cryptoswap.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

**Then connect without password:**
```powershell
ssh root@cryptoswap.com
```

---

### Option 3: Temporarily Allow Root Login with Password (Emergency)

**In VNC Console:**
```bash
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl restart sshd
```

---

## 🔧 VNC Caps Lock Issue - SOLVED!

**Problem:** VNC has INVERTED Caps Lock behavior
- Caps Lock OFF → Types UPPERCASE
- Caps Lock ON → Types lowercase

**Solution:** Keep your **local Caps Lock ON** when using VNC, then commands work correctly.

---

## 📊 Current Deployment Status

### ✅ Working:
- PostgreSQL container
- Redis container  
- Nginx container
- Backend container (likely)

### 🔧 Needs Fix:
- Frontend container (TypeScript build error)
- SSH access (password auth disabled)

### Next Steps:
1. Re-enable SSH password auth (Option 1 above)
2. Fix TypeScript issue with Python script
3. Rebuild frontend container
4. Verify all containers are healthy
5. Set up SSL certificates
6. Test application at https://cryptoswap.com

---

## 🎯 Quick Commands to Run in VNC (Caps Lock ON)

```bash
cd /opt/cswap-dex

# Fix SSH access
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Pull latest code
git pull origin master

# Run Python fix for TypeScript
python3 fixts.py

# Rebuild frontend
docker compose up -d --build frontend

# Check status
docker compose ps
```

