# CSwap DEX Server Reinstall Options

## ⚠️ IMPORTANT: Choose Your Approach

### Option 1: Quick Fix on Current Server (KEEP SAME IP) ⚡
**Pros:**
- ✅ Keep IP: 144.202.83.16 (no DNS change)
- ✅ Fast (2-3 minutes)
- ✅ Less destructive

**Cons:**
- ⚠️ Builds on existing (potentially messy) system

**How:** Run `run-init-v2.bat` (applies new setup script)

---

### Option 2: Fresh Server (NEW IP) 🆕
**Pros:**
- ✅ 100% clean slate
- ✅ Guaranteed working setup
- ✅ No baggage from old attempts

**Cons:**
- ⚠️ **New IP address** (must update DNS A record)
- ⏱️ Takes 5-10 minutes

**How:** Run `provision-new-server.ps1`

---

## 🎯 RECOMMENDATION

**Go with Option 1 first** - if it fails, we'll do Option 2.

---

## Files Created:

1. **server-init-v2.sh** - Improved initialization script
2. **run-init-v2.bat** - Applies new script to current server (keeps IP)
3. **provision-new-server.ps1** - Creates fresh server (new IP)

---

## Quick Start

### Option 1 (Keep IP):
```powershell
.\run-init-v2.bat
```

### Option 2 (New Server):
1. Edit `provision-new-server.ps1` - add your API key
2. Run: `.\provision-new-server.ps1`
3. Wait 5 minutes
4. Update DNS: cryptoswap.com → new IP

---

## Current Server Info
- IP: 144.202.83.16
- Password: t9%NnB3XpnF5s*KV
- Status: Running (with issues)

