# 🎯 FINAL FIX - Copy/Paste Into Vultr Console

## Step 1: Navigate to directory
```bash
cd /opt/cswap-dex
```

## Step 2: Create proper .env file
```bash
cat > .env << 'EOF'
POSTGRES_PASSWORD=Pass123
REDIS_PASSWORD=Pass456
NODE_ENV=production
EOF
```

## Step 3: Verify/Fix docker-compose.yml line 77
```bash
sed -i '77s/.*/      test: ["CMD", "redis-cli", "ping"]/' docker-compose.yml
```

## Step 4: Verify Dockerfiles exist
```bash
ls -la backend/Dockerfile frontend/Dockerfile
```

If either is missing, the files are available in your Windows directory at:
- `C:\Users\CryptoSwap\Desktop\Cswap Web UNI\cswap-dex\backend\Dockerfile`
- `C:\Users\CryptoSwap\Desktop\Cswap Web UNI\cswap-dex\frontend\Dockerfile`

## Step 5: Start fresh deployment
```bash
docker compose down -v
docker compose up -d --build
```

## Step 6: Monitor progress (wait 2-3 minutes for builds)
```bash
# Watch build progress
docker compose logs -f
```

Press Ctrl+C to stop watching logs.

## Step 7: Check final status
```bash
docker compose ps
```

You should see all 5 containers running:
- backend
- frontend  
- postgres
- redis
- nginx

## Step 8: Test the application
```bash
# Test nginx
curl -I http://localhost

# Test backend API  
curl http://localhost:8000/health

# Test frontend
curl http://localhost:3000
```

## Step 9: Check logs if any issues
```bash
# Backend logs
docker compose logs backend

# Frontend logs
docker compose logs frontend

# Nginx logs
docker compose logs nginx
```

## 🎯 Expected Result
- Nginx should respond on port 80/443
- Backend API on port 8000
- Frontend on port 3000
- All containers in "Up" status

## 🔧 If containers are crashing:
1. Check logs: `docker compose logs [service-name]`
2. Check if ports are in use: `netstat -tulpn | grep -E ':(80|443|3000|8000|5432|6379)'`
3. Verify package.json exists: `ls backend/package.json frontend/package.json`

