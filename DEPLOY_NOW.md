# Deploy CSwap DEX - Quick Commands

## Step 1: Push Deployment Files to GitHub

**On Windows:**

```powershell
cd "C:\Users\CryptoSwap\Desktop\Cswap Web UNI"

# Double-click sync-to-github.bat
# OR run in PowerShell:
.\sync-to-github.bat
```

If you get authentication errors, you need a GitHub Personal Access Token:
1. Go to: https://github.com/settings/tokens
2. Generate new token (classic) with `repo` scope
3. When pushing, use token as password

## Step 2: Update Server with New Files

**On Windows:**

```powershell
# Double-click update-server.bat
# OR run:
.\update-server.bat
```

## Step 3: Configure Environment on Server

**SSH to server:**

```bash
ssh root@cryptoswap.com

# Switch to app user
su - cswap
cd /opt/cswap-dex

# Now .env.production should exist!
cp .env.production .env

# Edit with your secrets
nano .env
```

**Required changes in .env:**
```bash
# Generate passwords with: openssl rand -base64 32

POSTGRES_PASSWORD=<CHANGE_THIS>
REDIS_PASSWORD=<CHANGE_THIS>
JWT_SECRET=<CHANGE_THIS>
JWT_REFRESH_SECRET=<CHANGE_THIS>
SESSION_SECRET=<CHANGE_THIS>
API_KEY_SALT=<CHANGE_THIS>
INTERNAL_API_KEY=<CHANGE_THIS>
```

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

## Step 4: Set Up SSL

**Exit to root:**

```bash
exit  # Back to root
./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
```

## Step 5: Deploy Application

**Switch back to cswap user:**

```bash
su - cswap
cd /opt/cswap-dex
./deploy.sh
```

## Step 6: Verify

```bash
./health-check.sh --verbose

# Test the site
curl https://cryptoswap.com
```

## 🎉 Done!

Your CSwap DEX is live at **https://cryptoswap.com**

---

## Quick Reference

**Update code on server (after making local changes):**

1. Commit locally: `git add . && git commit -m "message" && git push`
2. Update server: Run `update-server.bat` OR SSH and run `cd /opt/cswap-dex && ./deploy.sh`

**View logs:**
```bash
ssh root@cryptoswap.com
su - cswap
cd /opt/cswap-dex
docker compose logs -f
```

**Check status:**
```bash
cswap-status
```

**Health check:**
```bash
./health-check.sh
```

