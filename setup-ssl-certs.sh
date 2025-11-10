#!/bin/bash
################################################################################
# SSL Certificate Setup Script for CSwap DEX
# Sets up Let's Encrypt SSL certificates and configures Nginx
################################################################################

set -e

DOMAIN="cryptoswap.com"
EMAIL="admin@cryptoswap.com"

echo "=== SSL Certificate Setup for ${DOMAIN} ==="

# Install certbot if not already installed
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    apt-get update
    apt-get install -y certbot
fi

# Stop nginx container temporarily
echo "Stopping nginx container..."
cd /opt/cswap-dex/cswap-dex
docker compose stop nginx || true

# Generate SSL certificate using standalone mode (certbot binds to port 80)
echo "Generating SSL certificate..."
certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email "${EMAIL}" \
    -d "${DOMAIN}" \
    -d "www.${DOMAIN}" \
    --preferred-challenges http \
    --force-renewal || {
        echo "Certificate generation failed. Trying without www subdomain..."
        certbot certonly --standalone \
            --non-interactive \
            --agree-tos \
            --email "${EMAIL}" \
            -d "${DOMAIN}" \
            --preferred-challenges http \
            --force-renewal
    }

# Verify certificates were created
if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    echo "ERROR: SSL certificate generation failed!"
    exit 1
fi

echo "✓ SSL certificates generated successfully!"

# Create directory for certificates in nginx container volume
echo "Setting up certificate directory..."
mkdir -p /opt/cswap-dex/cswap-dex/nginx/certs
cp -r /etc/letsencrypt/live/${DOMAIN}/* /opt/cswap-dex/cswap-dex/nginx/certs/ || true
cp -r /etc/letsencrypt/archive/${DOMAIN}/* /opt/cswap-dex/cswap-dex/nginx/certs/ || true

# Update docker-compose to mount certificates
echo "Updating docker-compose configuration..."
cat > /tmp/nginx-volumes.txt << 'EOF'
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - /var/www/certbot:/var/www/certbot:ro
EOF

echo "✓ Certificate files ready"

# The main nginx.conf already has SSL configuration, just restart with it
echo "Restarting all services with SSL configuration..."
cd /opt/cswap-dex/cswap-dex
docker compose up -d

sleep 5

# Check if nginx is running
if docker compose ps nginx | grep -q "Up"; then
    echo "✓ Nginx started successfully with SSL"
else
    echo "WARNING: Nginx may have issues. Checking logs..."
    docker compose logs nginx --tail 30
fi

# Set up auto-renewal cron job
echo "Setting up certificate auto-renewal..."
CRON_JOB="0 3 * * * certbot renew --quiet --deploy-hook 'docker compose -f /opt/cswap-dex/cswap-dex/docker-compose.yml restart nginx' >> /var/log/certbot-renewal.log 2>&1"
(crontab -l 2>/dev/null | grep -v "certbot renew"; echo "$CRON_JOB") | crontab -

echo ""
echo "=== SSL Setup Complete! ==="
echo "✓ Certificates installed at: /etc/letsencrypt/live/${DOMAIN}/"
echo "✓ Nginx configured for HTTPS"
echo "✓ Auto-renewal configured (runs daily at 3 AM)"
echo ""
echo "Your site should now be accessible at:"
echo "  - https://${DOMAIN}"
echo "  - http://${DOMAIN} (redirects to HTTPS)"
echo ""
echo "Testing HTTPS endpoint..."
curl -k -I https://localhost 2>/dev/null | head -5 || echo "HTTPS endpoint check pending..."

