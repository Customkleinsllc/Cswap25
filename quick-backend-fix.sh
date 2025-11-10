#!/bin/bash
set -e

cd /opt/cswap-dex

echo "=== Fixing backend Dockerfile to use ts-node ==="
cat > /opt/cswap-dex/backend/Dockerfile << 'EOFBACK'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8000
CMD ["npx", "ts-node", "src/index.ts"]
EOFBACK

echo "=== Rebuilding backend only ==="
docker compose build --no-cache backend

echo "=== Restarting backend ==="
docker compose up -d backend

echo "=== Waiting 5 seconds ==="
sleep 5

echo "=== Backend logs ==="
docker compose logs --tail=30 backend

echo "=== All container status ==="
docker compose ps

