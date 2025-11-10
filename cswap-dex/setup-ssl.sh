#!/bin/bash
################################################################################
# SSL/TLS Certificate Setup Script
#
# This script installs certbot and generates Let's Encrypt SSL certificates
# for the CSwap DEX application
################################################################################

set -e

DOMAIN="${1:-cryptoswap.com}"
EMAIL="${2:-admin@${DOMAIN}}"

echo "=== SSL Certificate Setup for ${DOMAIN} ==="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
   echo "Please run as root or with sudo"
   exit 1
fi

# Install certbot if not already installed
if ! command -v certbot &> /dev/null; then
    echo "Installing certbot..."
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
fi

# Stop nginx temporarily to allow certbot to bind to port 80
echo "Stopping nginx..."
docker compose -f /opt/cswap-dex/cswap-dex/docker-compose.yml exec nginx nginx -s stop || true

# Generate SSL certificate
echo "Generating SSL certificate for ${DOMAIN}..."
certbot certonly --standalone \
    --non-interactive \
    --agree-tos \
    --email "${EMAIL}" \
    -d "${DOMAIN}" \
    -d "www.${DOMAIN}" \
    --preferred-challenges http

# Verify certificates were created
if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    echo "ERROR: SSL certificate generation failed!"
    exit 1
fi

echo "SSL certificates generated successfully!"

# Update nginx configuration to use SSL
echo "Switching to HTTPS configuration..."
cd /opt/cswap-dex/cswap-dex
cp nginx/nginx.conf nginx/nginx.conf.backup
# The main nginx.conf already has SSL configuration

# Restart nginx with SSL configuration
echo "Restarting nginx with SSL..."
docker compose restart nginx

# Set up auto-renewal
echo "Setting up certificate auto-renewal..."
(crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --post-hook 'docker compose -f /opt/cswap-dex/cswap-dex/docker-compose.yml restart nginx'") | crontab -

echo "=== SSL Setup Complete! ==="
echo "Your site is now accessible at https://${DOMAIN}"
echo "Certificates will auto-renew every 90 days"

