#!/bin/bash

################################################################################
# Permission Setup Script
# 
# This script sets correct permissions for all deployment scripts and files
################################################################################

echo "Setting up file permissions for CSwap DEX deployment scripts..."

# Make all shell scripts executable
chmod +x vultr-provision.sh
chmod +x server-init.sh
chmod +x setup-ssl.sh
chmod +x deploy.sh
chmod +x health-check.sh

echo "✓ Made shell scripts executable"

# Secure environment file if it exists
if [ -f "cswap-dex/.env" ]; then
    chmod 600 cswap-dex/.env
    echo "✓ Secured .env file (600)"
fi

if [ -f "cswap-dex/.env.production" ]; then
    chmod 600 cswap-dex/.env.production
    echo "✓ Secured .env.production file (600)"
fi

# Set appropriate permissions for nginx config
if [ -f "cswap-dex/nginx/nginx.conf" ]; then
    chmod 644 cswap-dex/nginx/nginx.conf
    echo "✓ Set nginx.conf permissions (644)"
fi

# Set appropriate permissions for docker-compose
if [ -f "cswap-dex/docker-compose.yml" ]; then
    chmod 644 cswap-dex/docker-compose.yml
    echo "✓ Set docker-compose.yml permissions (644)"
fi

echo ""
echo "✓ All permissions set successfully!"
echo ""
echo "You can now run the scripts:"
echo "  ./vultr-provision.sh - Provision server"
echo "  ./server-init.sh - Initialize server"
echo "  ./setup-ssl.sh - Setup SSL certificates"
echo "  ./deploy.sh - Deploy application"
echo "  ./health-check.sh - Check system health"

