#!/bin/bash
set -e

echo "=== CSwap DEX Deployment Script ==="
cd /opt/cswap-dex/cswap-dex

echo "=== Pulling latest changes ==="
git fetch origin
git reset --hard origin/master

echo "=== Using HTTP-only Nginx config (no SSL yet) ==="
cp nginx/nginx-http-only.conf nginx/nginx.conf

echo "=== Stopping all containers ==="
docker compose down

echo "=== Building containers ==="
docker compose build

echo "=== Starting services ==="
docker compose up -d

echo "=== Waiting for services to start ==="
sleep 20

echo "=== Container status ==="
docker compose ps

echo "=== Backend logs ==="
docker compose logs backend --tail 40

echo "=== Frontend logs ==="
docker compose logs frontend --tail 20

echo "=== Nginx logs ==="
docker compose logs nginx --tail 20

echo "=== Testing endpoints ==="
echo "Backend health:"
curl -f http://localhost:8000/health || echo "Backend health check failed"

echo ""
echo "Nginx status:"
curl -I http://localhost || echo "Nginx check failed"

echo ""
echo "=== Deployment complete! ==="
echo "Access the site at: http://149.28.229.49"

