#!/bin/bash
# Upload production Dockerfile to server

cat > /tmp/frontend-dockerfile << 'EOF'
# Multi-stage build for production
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the frontend
RUN npm run build

# Production stage - serve with a lightweight server
FROM node:18-alpine

WORKDIR /app

# Install serve to host static files
RUN npm install -g serve

# Copy built files from builder
COPY --from=builder /app/dist ./dist

# Expose port
EXPOSE 3000

# Set environment
ENV NODE_ENV=production

# Serve the static files
CMD ["serve", "-s", "dist", "-l", "3000"]
EOF

# Upload to server
scp /tmp/frontend-dockerfile root@104.238.152.227:/opt/cswap-dex/cswap-dex/frontend/Dockerfile

# Rebuild on server
ssh root@104.238.152.227 "cd /opt/cswap-dex && docker compose build frontend --no-cache && docker compose up -d frontend"

echo "Frontend rebuilt with production Dockerfile!"

