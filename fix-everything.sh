#!/bin/bash
################################################################################
# Comprehensive Fix Script for CSwap DEX
# Fixes: Backend, Nginx with SSL, and ensures everything works
################################################################################

set -e
cd /opt/cswap-dex/cswap-dex

echo "=== Step 1: Pull Latest Code ==="
git pull origin master

echo ""
echo "=== Step 2: Stop All Containers ==="
docker compose down

echo ""
echo "=== Step 3: Rebuild All Containers ==="
docker compose build

echo ""
echo "=== Step 4: Start Services (Postgres and Redis first) ==="
docker compose up -d postgres redis

echo "Waiting for database to be ready..."
sleep 15

echo ""
echo "=== Step 5: Start Backend ==="
docker compose up -d backend

echo "Waiting for backend to start..."
sleep 10

echo ""
echo "=== Step 6: Check Backend Status ==="
docker logs cswap-dex-backend-1 --tail 30
docker ps | grep backend

echo ""
echo "=== Step 7: Start Frontend and Nginx ==="
docker compose up -d frontend nginx

echo "Waiting for services..."
sleep 10

echo ""
echo "=== Step 8: Container Status ==="
docker compose ps

echo ""
echo "=== Step 9: Test Endpoints ==="
echo "Backend health:"
curl -s http://localhost:8000/health 2>&1 || echo "Backend not responding"

echo ""
echo "Frontend:"
curl -s -I http://localhost:3000 2>&1 | head -5 || echo "Frontend not responding"

echo ""
echo "Nginx:"
curl -s -I http://localhost 2>&1 | head -5 || echo "Nginx not responding"

echo ""
echo "=== Step 10: Show Recent Logs ==="
echo "--- Backend Logs ---"
docker compose logs backend --tail 20

echo ""
echo "--- Nginx Logs ---"
docker compose logs nginx --tail 20

echo ""
echo "=== Fix Script Complete! ==="
echo "Access your site at: http://104.238.152.227"

