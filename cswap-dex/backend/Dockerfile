# Backend Dockerfile for CSwap DEX
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (use npm install if package-lock.json doesn't exist)
RUN if [ -f package-lock.json ]; then npm ci --only=production; else npm install --production; fi

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build 2>/dev/null || echo "No build script, skipping"

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start application
CMD ["node", "src/index.js"]

