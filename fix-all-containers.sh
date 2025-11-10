#!/bin/bash
set -e

cd /opt/cswap-dex

echo "=== Fixing nginx config ==="
cat > /opt/cswap-dex/nginx/nginx.conf << 'EOFNGINX'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    
    upstream backend_api {
        server backend:8000;
        keepalive 32;
    }
    
    upstream frontend_app {
        server frontend:3000;
        keepalive 32;
    }
    
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/s;
    limit_req_zone $binary_remote_addr zone=general_limit:10m rate=50r/s;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    server {
        listen 80;
        listen [::]:80;
        server_name cryptoswap.com www.cryptoswap.com _;
        
        location / {
            proxy_pass http://frontend_app;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_cache_bypass $http_upgrade;
        }
        
        location /api/ {
            proxy_pass http://backend_api;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        location /health {
            proxy_pass http://backend_api/health;
            proxy_http_version 1.1;
        }
    }
}
EOFNGINX

echo "=== Fixing backend Dockerfile ==="
cat > /opt/cswap-dex/backend/Dockerfile << 'EOFBACK'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build || echo "Build failed, will use ts-node"
EXPOSE 8000
CMD ["sh", "-c", "if [ -d dist ]; then node dist/index.js; else npx ts-node src/index.ts; fi"]
EOFBACK

echo "=== Fixing frontend Dockerfile ==="
cat > /opt/cswap-dex/frontend/Dockerfile << 'EOFFRONT'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN chmod -R 755 node_modules/.bin
EXPOSE 3000
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
EOFFRONT

echo "=== Rebuilding all containers ==="
docker compose down
docker compose build --no-cache
docker compose up -d

echo "=== Waiting for containers to start ==="
sleep 10

echo "=== Container status ==="
docker compose ps

echo "=== Checking logs ==="
echo "--- Frontend ---"
docker compose logs --tail=20 frontend
echo "--- Backend ---"
docker compose logs --tail=20 backend
echo "--- Nginx ---"
docker compose logs --tail=20 nginx

