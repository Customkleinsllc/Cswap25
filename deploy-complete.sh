#!/bin/bash
################################################################################
# Complete Deployment Script for CSwap DEX
################################################################################

set -e  # Exit on error

echo "========================================="
echo "  CSwap DEX Complete Deployment"
echo "========================================="
echo ""

cd /opt/cswap-dex

# Step 1: Verify Dockerfiles exist
echo "[1/7] Checking Dockerfiles..."
if [ ! -f "backend/Dockerfile" ]; then
    echo "ERROR: backend/Dockerfile not found!"
    exit 1
fi
if [ ! -f "frontend/Dockerfile" ]; then
    echo "ERROR: frontend/Dockerfile not found!"
    exit 1
fi
echo "✓ Dockerfiles found"
echo ""

# Step 2: Verify docker-compose.yml
echo "[2/7] Checking docker-compose.yml..."
if [ ! -f "docker-compose.yml" ]; then
    echo "ERROR: docker-compose.yml not found!"
    exit 1
fi
echo "✓ docker-compose.yml found"
echo ""

# Step 3: Verify .env file
echo "[3/7] Checking .env file..."
if [ ! -f ".env" ]; then
    echo "WARNING: .env file not found, creating default..."
    cat > .env << 'EOF'
POSTGRES_PASSWORD=Pass123
REDIS_PASSWORD=Pass456
NODE_ENV=production
EOF
fi
echo "✓ .env file ready"
echo ""

# Step 4: Stop existing containers
echo "[4/7] Stopping existing containers..."
docker compose down
echo "✓ Containers stopped"
echo ""

# Step 5: Build and start containers
echo "[5/7] Building and starting containers (this may take 5-10 minutes)..."
docker compose up -d --build
echo "✓ Containers building/starting"
echo ""

# Step 6: Wait for containers to be ready
echo "[6/7] Waiting for containers to be healthy..."
sleep 30

# Step 7: Check container status
echo "[7/7] Checking container status..."
docker compose ps
echo ""

echo "========================================="
echo "  Deployment commands executed"
echo "========================================="
echo ""
echo "To check logs:"
echo "  docker compose logs -f"
echo ""
echo "To check specific service:"
echo "  docker compose logs backend"
echo "  docker compose logs frontend"
echo "  docker compose logs nginx"
echo ""

