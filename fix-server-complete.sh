#!/bin/bash
set -e

cd /opt/cswap-dex/cswap-dex

echo "=== Stopping all containers ==="
docker compose down

echo "=== Checking Nginx configuration ==="
if [ ! -f "nginx/nginx.conf" ]; then
    echo "ERROR: nginx.conf not found!"
    exit 1
fi

echo "=== Starting services ==="
docker compose up -d

echo "=== Waiting for services to start ==="
sleep 15

echo "=== Container status ==="
docker compose ps

echo "=== Backend logs ==="
docker compose logs backend --tail 30

echo "=== Frontend logs ==="
docker compose logs frontend --tail 30

echo "=== Nginx logs ==="
docker compose logs nginx --tail 30

echo "=== Testing backend health ==="
curl -f http://localhost:8000/health || echo "Backend health check failed"

echo "=== Testing frontend ==="
curl -f http://localhost:3000 || echo "Frontend check failed"

echo "=== Checking Nginx ==="
curl -I http://localhost || echo "Nginx check failed"

echo "=== Done! ==="

