#!/bin/bash
# CSwap DEX Server Initialization Script V2
# Improved based on lessons learned

set -e

echo "=== CSwap DEX Server Setup V2 ==="

# Update system
apt-get update
apt-get upgrade -y

# Install essentials
apt-get install -y curl wget git ufw fail2ban vim htop rsync python3

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl enable docker
systemctl start docker

# Install Docker Compose V2
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Configure Fail2Ban
systemctl enable fail2ban
systemctl start fail2ban

# SSH Hardening (but KEEP password auth enabled)
cat > /etc/ssh/sshd_config.d/99-custom.conf << 'SSHEOF'
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
MaxAuthTries 6
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2
SSHEOF

systemctl restart sshd

# Create application directory
mkdir -p /opt/cswap-dex
cd /opt

# Clone repository directly (no nesting!)
echo "Cloning CSwap DEX repository..."
git clone https://github.com/Customkleinsllc/Cswap25.git cswap-dex-temp

# Move contents up (avoid nested structure)
rsync -av cswap-dex-temp/ cswap-dex/
rm -rf cswap-dex-temp

cd /opt/cswap-dex

# Create proper .env file
cat > .env << 'ENVEOF'
# Database Configuration
POSTGRES_DB=cswap_dex
POSTGRES_USER=cswap_user
POSTGRES_PASSWORD=BwWkA5u12QBfuljdEohtwPQvjS72xePtO8msj
DATABASE_URL=postgresql://cswap_user:BwWkA5u12QBfuljdEohtwPQvjS72xePtO8msj@postgres:5432/cswap_dex

# Redis Configuration
REDIS_PASSWORD=d64LGqhfZ2xOIDSaWMyMOLyP3ImzJKGhCKoxF9
REDIS_URL=redis://:d64LGqhfZ2xOIDSaWMyMOLyP3ImzJKGhCKoxF9@redis:6379/0

# Application Configuration
NODE_ENV=production
PORT=8000
FRONTEND_PORT=3000
ENVEOF

# Set permissions
chmod 600 .env
chmod +x *.sh 2>/dev/null || true

# Install frontend dependencies
if [ -d "frontend" ]; then
    echo "Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
fi

# Install backend dependencies
if [ -d "backend" ]; then
    echo "Installing backend dependencies..."
    cd backend
    npm install
    cd ..
fi

# Create simplified Dockerfiles
echo "Creating optimized Dockerfiles..."

# Frontend Dockerfile
cat > frontend/Dockerfile << 'FRONTEOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
FRONTEOF

# Backend Dockerfile
cat > backend/Dockerfile << 'BACKEOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production || npm install
COPY . .
RUN npm run build 2>/dev/null || echo "No build script, skipping"
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"
CMD ["node", "src/index.js"]
BACKEOF

# Remove version attribute from docker-compose.yml
sed -i '/^version:/d' docker-compose.yml 2>/dev/null || true

echo "=== Setup Complete ==="
echo "Next steps:"
echo "1. cd /opt/cswap-dex"
echo "2. docker compose up -d"
echo "3. docker compose ps"
echo ""
echo "Server IP: $(curl -s ifconfig.me)"
echo "SSH: ssh root@$(curl -s ifconfig.me)"

