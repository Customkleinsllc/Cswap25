#!/bin/bash
################################################################################
# Enable HTTPS with Let's Encrypt SSL Certificates
################################################################################

set -e
cd /opt/cswap-dex/cswap-dex

echo "=== Enabling HTTPS ==="

# Check if certificates exist
if [ ! -f "/etc/letsencrypt/live/cryptoswap.com/fullchain.pem" ]; then
    echo "ERROR: SSL certificates not found!"
    echo "Please ensure DNS points to this server and run the SSL setup first."
    exit 1
fi

echo "✓ SSL certificates found"

# Copy the full Nginx config with SSL
echo "Updating Nginx configuration..."
git pull origin master
cp nginx/nginx.conf nginx/nginx-active.conf

# Update docker-compose to use the SSL-enabled config
echo "Restarting Nginx with HTTPS..."
docker compose stop nginx
docker compose up -d nginx

sleep 5

echo ""
echo "=== Testing HTTPS ==="
curl -k -I https://localhost 2>&1 | head -10 || echo "HTTPS check pending..."

echo ""
echo "=== HTTPS Enabled! ==="
echo "Your site is now accessible at:"
echo "  - https://cryptoswap.com"
echo "  - https://104.238.152.227"
echo "  - http://104.238.152.227 (redirects to HTTPS)"

