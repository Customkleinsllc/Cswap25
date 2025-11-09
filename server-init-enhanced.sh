#!/bin/bash

################################################################################
# Enhanced Server Initialization Script for CSwap DEX Exchange
# 
# This script sets up a fresh Ubuntu 22.04 server with all necessary
# dependencies and automatically clones the CSwap repository.
#
# Features:
# - System updates and essential packages
# - Docker and Docker Compose V2 installation
# - Certbot for SSL certificates
# - UFW firewall configuration
# - SSH hardening
# - Application directory setup
# - AUTOMATIC repository cloning
# - Non-root user for Docker operations
#
# Usage:
#   Run as root on a fresh Ubuntu 22.04 server:
#   ./server-init-enhanced.sh
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/opt/cswap-dex"
APP_USER="cswap"
SSH_PORT="22"
GIT_REPO="https://github.com/Customkleinsllc/Cswap25.git"
GIT_BRANCH="main"

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
    log_success "Running as root"
}

# Update system
update_system() {
    log_info "Updating system packages..."
    export DEBIAN_FRONTEND=noninteractive
    
    apt-get update -qq
    apt-get upgrade -y -qq
    apt-get dist-upgrade -y -qq
    
    log_success "System updated"
}

# Install essential packages
install_essentials() {
    log_info "Installing essential packages..."
    
    apt-get install -y -qq \
        curl \
        wget \
        git \
        vim \
        htop \
        ufw \
        fail2ban \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        jq \
        netcat
    
    log_success "Essential packages installed (including git)"
}

# Install Docker
install_docker() {
    log_info "Installing Docker..."
    
    # Remove old versions if they exist
    apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Enable Docker service
    systemctl enable docker
    systemctl start docker
    
    log_success "Docker installed successfully"
    docker --version
    docker compose version
}

# Install Certbot
install_certbot() {
    log_info "Installing Certbot for SSL certificates..."
    
    apt-get install -y -qq certbot python3-certbot-nginx
    
    log_success "Certbot installed successfully"
    certbot --version
}

# Configure UFW firewall
configure_firewall() {
    log_info "Configuring UFW firewall..."
    
    # Disable UFW first to avoid lockout
    ufw --force disable
    
    # Set default policies
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow SSH
    ufw allow ${SSH_PORT}/tcp comment 'SSH'
    
    # Allow HTTP and HTTPS
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    
    # Enable UFW
    ufw --force enable
    
    log_success "Firewall configured and enabled"
    ufw status verbose
}

# Configure Fail2Ban
configure_fail2ban() {
    log_info "Configuring Fail2Ban..."
    
    # Create local jail configuration
    cat > /etc/fail2ban/jail.local <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
destemail = admin@cryptoswap.com
sendername = Fail2Ban
action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-limit-req]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
EOF
    
    # Restart Fail2Ban
    systemctl enable fail2ban
    systemctl restart fail2ban
    
    log_success "Fail2Ban configured"
}

# Create application user
create_app_user() {
    log_info "Creating application user: ${APP_USER}..."
    
    if id "${APP_USER}" &>/dev/null; then
        log_warning "User ${APP_USER} already exists"
    else
        useradd -r -m -s /bin/bash -d /home/${APP_USER} ${APP_USER}
        log_success "User ${APP_USER} created"
    fi
    
    # Add user to docker group
    usermod -aG docker ${APP_USER}
    log_success "User ${APP_USER} added to docker group"
}

# Create application directory
create_app_directory() {
    log_info "Creating application directory: ${APP_DIR}..."
    
    mkdir -p ${APP_DIR}
    
    # Create subdirectories
    mkdir -p ${APP_DIR}/logs
    mkdir -p ${APP_DIR}/backups
    mkdir -p ${APP_DIR}/ssl
    mkdir -p ${APP_DIR}/data
    
    # Set ownership to app user
    chown -R ${APP_USER}:${APP_USER} ${APP_DIR}
    chmod 755 ${APP_DIR}
    
    log_success "Application directory created"
}

# Clone repository
clone_repository() {
    log_info "Cloning CSwap DEX repository..."
    
    # Check if directory is empty
    if [ "$(ls -A ${APP_DIR})" ]; then
        log_warning "Directory ${APP_DIR} is not empty, skipping clone"
        return 0
    fi
    
    # Clone as the app user
    su - ${APP_USER} -c "git clone ${GIT_REPO} ${APP_DIR}/repo"
    
    if [ $? -eq 0 ]; then
        # Move contents from repo subdirectory to APP_DIR
        su - ${APP_USER} -c "shopt -s dotglob && mv ${APP_DIR}/repo/* ${APP_DIR}/ && rmdir ${APP_DIR}/repo"
        
        log_success "Repository cloned successfully"
        log_info "Repository: ${GIT_REPO}"
        log_info "Location: ${APP_DIR}"
        
        # Show current branch and latest commit
        cd ${APP_DIR}
        CURRENT_BRANCH=$(su - ${APP_USER} -c "cd ${APP_DIR} && git rev-parse --abbrev-ref HEAD")
        LATEST_COMMIT=$(su - ${APP_USER} -c "cd ${APP_DIR} && git log -1 --format='%h - %s'")
        
        log_info "Branch: ${CURRENT_BRANCH}"
        log_info "Latest commit: ${LATEST_COMMIT}"
    else
        log_error "Failed to clone repository"
        log_error "You can manually clone with: git clone ${GIT_REPO} ${APP_DIR}"
        return 1
    fi
}

# Configure SSH hardening
configure_ssh() {
    log_info "Configuring SSH security..."
    
    # Backup original sshd_config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    
    # Apply security settings
    sed -i 's/#PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
    sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
    
    # Add additional security settings
    cat >> /etc/ssh/sshd_config <<'EOF'

# Additional Security Settings
MaxAuthTries 3
MaxSessions 5
ClientAliveInterval 300
ClientAliveCountMax 2
Protocol 2
EOF
    
    # Restart SSH service
    systemctl restart sshd
    
    log_success "SSH hardening configured"
    log_warning "Root login is now restricted to SSH keys only"
}

# Set up automatic security updates
setup_auto_updates() {
    log_info "Setting up automatic security updates..."
    
    apt-get install -y -qq unattended-upgrades apt-listchanges
    
    # Configure automatic updates
    cat > /etc/apt/apt.conf.d/50unattended-upgrades <<'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF
    
    # Enable automatic updates
    cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
    
    log_success "Automatic security updates enabled"
}

# Configure system limits
configure_limits() {
    log_info "Configuring system limits..."
    
    cat >> /etc/security/limits.conf <<'EOF'

# CSwap DEX System Limits
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
EOF
    
    # Configure sysctl settings for better performance
    cat >> /etc/sysctl.conf <<'EOF'

# CSwap DEX System Configuration
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
vm.swappiness = 10
EOF
    
    sysctl -p > /dev/null
    
    log_success "System limits configured"
}

# Set up log rotation
setup_log_rotation() {
    log_info "Setting up log rotation..."
    
    cat > /etc/logrotate.d/cswap-dex <<'EOF'
/opt/cswap-dex/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 cswap cswap
    sharedscripts
    postrotate
        docker compose -f /opt/cswap-dex/docker-compose.yml restart > /dev/null 2>&1 || true
    endscript
}
EOF
    
    log_success "Log rotation configured"
}

# Install monitoring tools
install_monitoring() {
    log_info "Installing monitoring tools..."
    
    apt-get install -y -qq \
        sysstat \
        iotop \
        iftop \
        nethogs
    
    # Enable sysstat
    sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
    systemctl enable sysstat
    systemctl start sysstat
    
    log_success "Monitoring tools installed"
}

# Create deployment helper scripts
create_helper_scripts() {
    log_info "Creating helper scripts..."
    
    # Docker cleanup script
    cat > /usr/local/bin/docker-cleanup <<'EOF'
#!/bin/bash
echo "Cleaning up Docker resources..."
docker system prune -af --volumes
echo "Docker cleanup complete"
EOF
    chmod +x /usr/local/bin/docker-cleanup
    
    # Service status script
    cat > /usr/local/bin/cswap-status <<'EOF'
#!/bin/bash
cd /opt/cswap-dex
echo "=== CSwap DEX Service Status ==="
docker compose ps
echo ""
echo "=== Docker Stats ==="
docker stats --no-stream
EOF
    chmod +x /usr/local/bin/cswap-status
    
    # Service logs script
    cat > /usr/local/bin/cswap-logs <<'EOF'
#!/bin/bash
cd /opt/cswap-dex
docker compose logs -f --tail=100
EOF
    chmod +x /usr/local/bin/cswap-logs
    
    log_success "Helper scripts created"
    log_info "Available commands: cswap-status, cswap-logs, docker-cleanup"
}

# Copy deployment scripts to app directory
copy_deployment_scripts() {
    log_info "Setting up deployment scripts..."
    
    # Check if deployment scripts exist in current directory
    local scripts=("setup-ssl.sh" "deploy.sh" "health-check.sh")
    local copied=0
    
    for script in "${scripts[@]}"; do
        if [ -f "/root/${script}" ]; then
            cp "/root/${script}" "${APP_DIR}/"
            chown ${APP_USER}:${APP_USER} "${APP_DIR}/${script}"
            chmod +x "${APP_DIR}/${script}"
            ((copied++))
            log_info "Copied ${script} to ${APP_DIR}"
        fi
    done
    
    if [ $copied -gt 0 ]; then
        log_success "Deployment scripts set up (${copied} scripts copied)"
    else
        log_warning "No deployment scripts found in /root/"
        log_info "You can upload them later: setup-ssl.sh, deploy.sh, health-check.sh"
    fi
}

# Print summary
print_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║         Server Initialization Complete!                       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Server Configuration Summary:"
    echo "  ✓ System updated and secured"
    echo "  ✓ Docker and Docker Compose V2 installed"
    echo "  ✓ Certbot installed for SSL certificates"
    echo "  ✓ UFW firewall configured and enabled"
    echo "  ✓ Fail2Ban configured for intrusion prevention"
    echo "  ✓ SSH hardening applied"
    echo "  ✓ Application user '${APP_USER}' created"
    echo "  ✓ Application directory: ${APP_DIR}"
    echo "  ✓ Repository cloned from GitHub"
    echo "  ✓ Automatic security updates enabled"
    echo "  ✓ Monitoring tools installed"
    echo ""
    echo "Repository Information:"
    echo "  Repository: ${GIT_REPO}"
    echo "  Location: ${APP_DIR}"
    echo ""
    echo "Helper Commands:"
    echo "  cswap-status  - View service status and Docker stats"
    echo "  cswap-logs    - View service logs in real-time"
    echo "  docker-cleanup - Clean up unused Docker resources"
    echo ""
    echo "Next Steps:"
    echo "  1. Configure environment variables"
    echo "     su - ${APP_USER}"
    echo "     cd ${APP_DIR}"
    echo "     cp .env.production .env"
    echo "     nano .env  # Edit with your configuration"
    echo ""
    echo "  2. Set up SSL certificate"
    echo "     exit  # Back to root"
    echo "     ./setup-ssl.sh cryptoswap.com admin@cryptoswap.com"
    echo ""
    echo "  3. Deploy the application"
    echo "     su - ${APP_USER}"
    echo "     cd ${APP_DIR}"
    echo "     ./deploy.sh"
    echo ""
    log_success "Server is ready for deployment!"
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║      Enhanced Server Initialization for CSwap DEX             ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_root
    update_system
    install_essentials
    install_docker
    install_certbot
    configure_firewall
    configure_fail2ban
    create_app_user
    create_app_directory
    clone_repository
    configure_ssh
    setup_auto_updates
    configure_limits
    setup_log_rotation
    install_monitoring
    create_helper_scripts
    copy_deployment_scripts
    
    print_summary
}

# Run main function
main

