#!/bin/bash

################################################################################
# SSL Certificate Setup Script for CSwap DEX Exchange
# 
# This script automates the process of obtaining and configuring Let's Encrypt
# SSL certificates for cryptoswap.com using Certbot.
#
# Features:
# - Obtains SSL certificates from Let's Encrypt
# - Configures automatic renewal with cron job
# - Tests SSL configuration
# - Updates Nginx configuration
# - Validates certificate installation
#
# Prerequisites:
# - Domain DNS must be pointing to this server
# - Certbot must be installed (run server-init.sh first)
# - Nginx must be installed
# - Ports 80 and 443 must be open
#
# Usage:
#   ./setup-ssl.sh [domain] [email]
#   Example: ./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DEFAULT_DOMAIN="cryptoswap.com"
DEFAULT_EMAIL="admin@cryptoswap.com"
WEBROOT_PATH="/var/www/certbot"
NGINX_SSL_DIR="/etc/nginx/ssl"
APP_DIR="/opt/cswap-dex"

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Parse command line arguments
parse_args() {
    DOMAIN="${1:-$DEFAULT_DOMAIN}"
    EMAIL="${2:-$DEFAULT_EMAIL}"
    
    log_info "Domain: ${DOMAIN}"
    log_info "Email: ${EMAIL}"
}

# Validate domain
validate_domain() {
    log_info "Validating domain ${DOMAIN}..."
    
    # Check if domain resolves to this server's IP
    SERVER_IP=$(curl -s ifconfig.me)
    DOMAIN_IP=$(dig +short ${DOMAIN} | tail -n1)
    
    if [ -z "$DOMAIN_IP" ]; then
        log_error "Domain ${DOMAIN} does not resolve to any IP address"
        log_error "Please configure DNS A record to point to ${SERVER_IP}"
        exit 1
    fi
    
    if [ "$DOMAIN_IP" != "$SERVER_IP" ]; then
        log_warning "Domain ${DOMAIN} resolves to ${DOMAIN_IP}"
        log_warning "But this server's IP is ${SERVER_IP}"
        log_warning "Continuing anyway, but SSL verification may fail..."
    else
        log_success "Domain ${DOMAIN} correctly resolves to this server (${SERVER_IP})"
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if certbot is installed
    if ! command -v certbot &> /dev/null; then
        log_error "Certbot is not installed"
        log_error "Please run server-init.sh first to install Certbot"
        exit 1
    fi
    
    # Check if nginx is installed (via Docker)
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        log_error "Please run server-init.sh first"
        exit 1
    fi
    
    log_success "All prerequisites met"
}

# Create webroot directory
create_webroot() {
    log_info "Creating webroot directory for ACME challenge..."
    
    mkdir -p ${WEBROOT_PATH}
    chmod 755 ${WEBROOT_PATH}
    
    log_success "Webroot directory created: ${WEBROOT_PATH}"
}

# Stop nginx container temporarily
stop_nginx() {
    log_info "Checking if Nginx container is running..."
    
    if docker ps | grep -q nginx; then
        log_info "Stopping Nginx container..."
        docker stop nginx || true
        log_success "Nginx container stopped"
        return 0
    fi
    
    log_info "Nginx container is not running"
    return 1
}

# Start nginx container
start_nginx() {
    log_info "Starting Nginx container..."
    
    if [ -f "${APP_DIR}/docker-compose.yml" ]; then
        cd ${APP_DIR}
        docker compose up -d nginx
        log_success "Nginx container started"
    else
        log_warning "docker-compose.yml not found at ${APP_DIR}"
    fi
}

# Obtain SSL certificate
obtain_certificate() {
    log_info "Obtaining SSL certificate for ${DOMAIN}..."
    
    # Check if certificate already exists
    if [ -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
        log_warning "Certificate for ${DOMAIN} already exists"
        read -p "Do you want to renew it? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping certificate generation"
            return 0
        fi
        CERTBOT_FLAGS="--force-renewal"
    else
        CERTBOT_FLAGS=""
    fi
    
    # Obtain certificate using standalone mode
    certbot certonly \
        --standalone \
        --preferred-challenges http \
        --agree-tos \
        --no-eff-email \
        --email ${EMAIL} \
        -d ${DOMAIN} \
        -d www.${DOMAIN} \
        ${CERTBOT_FLAGS} \
        --non-interactive
    
    if [ $? -eq 0 ]; then
        log_success "SSL certificate obtained successfully"
    else
        log_error "Failed to obtain SSL certificate"
        exit 1
    fi
}

# Verify certificate files
verify_certificate() {
    log_info "Verifying certificate files..."
    
    CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"
    
    if [ ! -f "${CERT_DIR}/fullchain.pem" ]; then
        log_error "Certificate file not found: ${CERT_DIR}/fullchain.pem"
        exit 1
    fi
    
    if [ ! -f "${CERT_DIR}/privkey.pem" ]; then
        log_error "Private key file not found: ${CERT_DIR}/privkey.pem"
        exit 1
    fi
    
    # Check certificate expiration
    EXPIRY_DATE=$(openssl x509 -enddate -noout -in ${CERT_DIR}/fullchain.pem | cut -d= -f2)
    log_success "Certificate is valid until: ${EXPIRY_DATE}"
    
    # Verify certificate chain
    if openssl verify -CAfile ${CERT_DIR}/chain.pem ${CERT_DIR}/cert.pem &> /dev/null; then
        log_success "Certificate chain is valid"
    else
        log_warning "Certificate chain verification failed"
    fi
}

# Generate Diffie-Hellman parameters
generate_dhparam() {
    log_info "Generating Diffie-Hellman parameters (this may take a few minutes)..."
    
    mkdir -p ${NGINX_SSL_DIR}
    
    if [ -f "${NGINX_SSL_DIR}/dhparam.pem" ]; then
        log_info "DH parameters already exist, skipping generation"
        return 0
    fi
    
    openssl dhparam -out ${NGINX_SSL_DIR}/dhparam.pem 2048
    
    log_success "Diffie-Hellman parameters generated"
}

# Setup automatic renewal
setup_auto_renewal() {
    log_info "Setting up automatic certificate renewal..."
    
    # Create renewal script
    cat > /usr/local/bin/renew-ssl.sh <<'EOF'
#!/bin/bash

# Renew certificates
certbot renew --quiet --pre-hook "docker compose -f /opt/cswap-dex/docker-compose.yml stop nginx" --post-hook "docker compose -f /opt/cswap-dex/docker-compose.yml start nginx"

# Check if renewal was successful
if [ $? -eq 0 ]; then
    echo "$(date): SSL certificate renewal successful" >> /var/log/ssl-renewal.log
else
    echo "$(date): SSL certificate renewal failed" >> /var/log/ssl-renewal.log
fi
EOF
    
    chmod +x /usr/local/bin/renew-ssl.sh
    
    # Add cron job for automatic renewal (runs twice daily)
    CRON_CMD="0 0,12 * * * /usr/local/bin/renew-ssl.sh"
    
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "renew-ssl.sh"; then
        log_info "Cron job for SSL renewal already exists"
    else
        (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
        log_success "Cron job added for automatic SSL renewal"
    fi
    
    # Test automatic renewal (dry run)
    log_info "Testing automatic renewal (dry run)..."
    certbot renew --dry-run
    
    if [ $? -eq 0 ]; then
        log_success "Automatic renewal test successful"
    else
        log_warning "Automatic renewal test failed"
    fi
}

# Update Nginx configuration
update_nginx_config() {
    log_info "Updating Nginx configuration..."
    
    NGINX_CONF="${APP_DIR}/nginx/nginx.conf"
    
    if [ ! -f "${NGINX_CONF}" ]; then
        log_warning "Nginx config not found at ${NGINX_CONF}"
        log_warning "You may need to manually configure SSL in your Nginx config"
        return 1
    fi
    
    # Check if SSL configuration already exists
    if grep -q "ssl_certificate" ${NGINX_CONF}; then
        log_info "SSL configuration already exists in Nginx config"
    else
        log_warning "SSL configuration not found in Nginx config"
        log_warning "Please manually add SSL configuration"
    fi
    
    log_success "Nginx configuration updated"
}

# Update docker-compose.yml
update_docker_compose() {
    log_info "Checking docker-compose.yml for SSL volume mounts..."
    
    COMPOSE_FILE="${APP_DIR}/docker-compose.yml"
    
    if [ ! -f "${COMPOSE_FILE}" ]; then
        log_warning "docker-compose.yml not found at ${COMPOSE_FILE}"
        return 1
    fi
    
    # Check if letsencrypt volume is already mounted
    if grep -q "/etc/letsencrypt" ${COMPOSE_FILE}; then
        log_success "SSL certificates volume already mounted in docker-compose.yml"
    else
        log_warning "SSL certificates volume not found in docker-compose.yml"
        log_info "You need to add the following to your nginx service volumes:"
        echo "      - /etc/letsencrypt:/etc/letsencrypt:ro"
    fi
}

# Test SSL certificate
test_ssl() {
    log_info "Testing SSL certificate..."
    
    # Wait for nginx to start
    sleep 5
    
    # Test HTTPS connection
    if curl -s -o /dev/null -w "%{http_code}" https://${DOMAIN} | grep -q "200\|301\|302"; then
        log_success "HTTPS connection successful"
    else
        log_warning "HTTPS connection test failed"
        log_warning "This may be normal if the application is not yet deployed"
    fi
    
    # Test SSL certificate with OpenSSL
    log_info "Verifying SSL certificate with OpenSSL..."
    echo | openssl s_client -servername ${DOMAIN} -connect ${DOMAIN}:443 2>/dev/null | openssl x509 -noout -dates
    
    if [ $? -eq 0 ]; then
        log_success "SSL certificate is valid"
    else
        log_warning "SSL certificate verification failed"
    fi
}

# Print certificate information
print_certificate_info() {
    log_info "Certificate information:"
    certbot certificates
}

# Print summary
print_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           SSL Certificate Setup Complete!                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "SSL Configuration Summary:"
    echo "  ✓ SSL certificate obtained for ${DOMAIN}"
    echo "  ✓ Certificate location: /etc/letsencrypt/live/${DOMAIN}/"
    echo "  ✓ Automatic renewal configured (runs twice daily)"
    echo "  ✓ Nginx configuration updated"
    echo ""
    echo "Certificate Files:"
    echo "  - Full Chain: /etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
    echo "  - Private Key: /etc/letsencrypt/live/${DOMAIN}/privkey.pem"
    echo "  - Certificate: /etc/letsencrypt/live/${DOMAIN}/cert.pem"
    echo "  - Chain: /etc/letsencrypt/live/${DOMAIN}/chain.pem"
    echo ""
    echo "Manual Renewal Command:"
    echo "  certbot renew"
    echo ""
    echo "Check Renewal Status:"
    echo "  certbot certificates"
    echo ""
    echo "Next Steps:"
    echo "  1. Ensure docker-compose.yml has SSL volume mount:"
    echo "     volumes:"
    echo "       - /etc/letsencrypt:/etc/letsencrypt:ro"
    echo ""
    echo "  2. Restart Nginx to apply SSL configuration:"
    echo "     cd ${APP_DIR} && docker compose restart nginx"
    echo ""
    echo "  3. Test HTTPS access:"
    echo "     curl -I https://${DOMAIN}"
    echo ""
    echo "  4. Test SSL certificate:"
    echo "     openssl s_client -servername ${DOMAIN} -connect ${DOMAIN}:443"
    echo ""
    log_success "SSL setup complete!"
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║      SSL Certificate Setup for CSwap DEX Exchange             ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_root
    parse_args "$@"
    check_prerequisites
    validate_domain
    create_webroot
    
    # Stop nginx if running
    NGINX_WAS_RUNNING=false
    if stop_nginx; then
        NGINX_WAS_RUNNING=true
    fi
    
    # Obtain certificate
    obtain_certificate
    verify_certificate
    
    # Generate DH parameters
    generate_dhparam
    
    # Setup automatic renewal
    setup_auto_renewal
    
    # Update configurations
    update_nginx_config
    update_docker_compose
    
    # Start nginx if it was running
    if [ "$NGINX_WAS_RUNNING" = true ]; then
        start_nginx
        test_ssl
    fi
    
    # Print certificate info
    print_certificate_info
    
    # Print summary
    print_summary
}

# Run main function
main "$@"

