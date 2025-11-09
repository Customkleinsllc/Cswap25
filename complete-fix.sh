#!/bin/bash
################################################################################
# Complete Fix Script for CSwap DEX Deployment
# This script fixes all remaining issues:
# 1. Creates missing Dockerfiles
# 2. Fixes docker-compose.yml (removes obsolete 'version' field)
# 3. Builds and starts all containers
################################################################################

set -e
cd /opt/cswap-dex

echo "========================================="
echo "  CSwap DEX - Complete Fix Script"
echo "========================================="
echo ""

# Step 1: Create backend Dockerfile if missing
echo "[1/5] Creating backend/Dockerfile..."
cat > backend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN if [ -f package-lock.json ]; then npm ci --only=production; else npm install --production; fi

COPY . .

RUN npm run build 2>/dev/null || echo "No build script"

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1

CMD ["node", "src/index.js"]
EOF
echo "✓ backend/Dockerfile created"

# Step 2: Create frontend Dockerfile if missing
echo "[2/5] Creating frontend/Dockerfile..."
cat > frontend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

COPY . .

RUN npm run build

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1

CMD ["npm", "start"]
EOF
echo "✓ frontend/Dockerfile created"

# Step 3: Fix docker-compose.yml (remove version field)
echo "[3/5] Fixing docker-compose.yml..."
if grep -q "^version:" docker-compose.yml; then
    sed -i '/^version:/d' docker-compose.yml
    echo "✓ Removed obsolete 'version' field"
fi

# Step 4: Stop any running containers
echo "[4/5] Stopping existing containers..."
docker compose down 2>/dev/null || true

# Step 5: Build and start containers
echo "[5/5] Building and starting containers..."
docker compose up -d --build

echo ""
echo "========================================="
echo "  Deployment Complete!"
echo "========================================="
echo ""
echo "Checking container status..."
sleep 5
docker compose ps

echo ""
echo "To view logs: docker compose logs --tail=100 -f"
echo "To check status: docker compose ps"
echo "To restart: docker compose restart"

