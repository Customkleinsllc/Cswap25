# 🔧 Complete Fix Instructions

## The Problem
1. ✗ Frontend/Backend Dockerfiles are missing
2. ⚠️ docker-compose.yml has obsolete 'version' field warning
3. 🔐 Root password login may be failing in VNC console

## ✅ Solution - Run This in Vultr Console

### Option 1: If you can log into the Vultr console

**Copy and paste this ENTIRE block:**

```bash
# Pull the latest fixes from GitHub
cd /opt/cswap-dex
git pull origin master

# Run the complete fix script
bash /opt/cswap-dex/complete-fix.sh

# Wait 2-3 minutes for containers to build, then check status
docker compose ps
docker compose logs --tail=50
```

### Option 2: If you're logged out and can't log back in

The VNC console at the top of the screen should show a login prompt. If the root password isn't working:

1. **In Vultr dashboard**, go to your server settings
2. Click **"View Console"** or **"Reset Root Password"**
3. Reset the password and note the new one
4. Log in with the new password
5. Then run the commands from Option 1

### Option 3: Use Vultr's "Startup Scripts" feature

1. Go to Vultr Dashboard → Your Server → Settings
2. Find **"Startup Scripts"** or **"User Data"**
3. Add this script:

```bash
#!/bin/bash
cd /opt/cswap-dex
git pull origin master
bash /opt/cswap-dex/complete-fix.sh
```

4. Reboot the server
5. Wait 5 minutes
6. Check if it's running: Go to http://cryptoswap.com

## 🎯 What the Fix Script Does

1. Creates `backend/Dockerfile` with proper Node.js setup
2. Creates `frontend/Dockerfile` with proper build configuration  
3. Removes the obsolete `version:` field from docker-compose.yml
4. Stops any running containers
5. Builds fresh container images
6. Starts all services (postgres, redis, backend, frontend, nginx)

## ✅ Verification

After running, you should see:

```
NAME                STATUS          PORTS
postgres            Up              0.0.0.0:5432->5432/tcp
redis               Up              0.0.0.0:6379->6379/tcp
backend             Up              0.0.0.0:8000->8000/tcp
frontend            Up              0.0.0.0:3000->3000/tcp
nginx               Up              0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp
```

## 🚨 If Something Goes Wrong

**View detailed logs:**
```bash
docker compose logs backend --tail=100
docker compose logs frontend --tail=100
```

**Restart everything:**
```bash
cd /opt/cswap-dex
docker compose down
docker compose up -d --build
```

**Check container status:**
```bash
docker compose ps
docker ps -a
```

## 📞 Next Steps

Once containers are running:
1. Set up SSL certificates (run `./setup-ssl.sh`)
2. Configure DNS to point to your server IP
3. Test the application at https://cryptoswap.com

