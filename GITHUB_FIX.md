# Fix GitHub Authentication Issue

## The Problem
Your server can't pull from the **private** GitHub repo because password authentication is disabled.

## ✅ FASTEST Solution: Make Repo Public Temporarily

### Step 1: Make Repo Public (2 minutes)
1. Go to: https://github.com/Customkleinsllc/Cswap25/settings
2. Scroll to bottom → **Danger Zone**
3. Click **"Change repository visibility"**
4. Select **"Make public"**
5. Type the repo name to confirm
6. Click **"I understand, change repository visibility"**

### Step 2: Pull Code on Server (paste in Vultr console)
```bash
cd /opt/cswap-dex
git pull origin master
ls -la backend/src/
ls -la frontend/src/
```

### Step 3: Make Repo Private Again (once deployment works)
1. Go back to: https://github.com/Customkleinsllc/Cswap25/settings
2. Scroll to bottom → **Danger Zone**
3. Click **"Change repository visibility"**
4. Select **"Make private"**

---

## Alternative: Use SSH Key (More Secure, Takes Longer)

If you want to keep it private, you'll need to:
1. Generate SSH key on server: `ssh-keygen -t ed25519 -C "server@cryptoswap.com"`
2. Add public key to GitHub: https://github.com/settings/keys
3. Clone using SSH URL instead of HTTPS

---

## Recommendation
**Make it public for now** - you can make it private again once everything is deployed and working. This is the fastest path to getting your DEX online.

