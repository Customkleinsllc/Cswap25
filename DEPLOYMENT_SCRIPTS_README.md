# CSwap DEX - Deployment Scripts

This directory contains all the automation scripts and configuration files needed to deploy the CSwap DEX Exchange on Vultr infrastructure.

## 📁 Files Overview

### Automation Scripts

| File | Purpose | Usage |
|------|---------|-------|
| `vultr-provision.sh` | Provisions a new Vultr server via API | `./vultr-provision.sh` |
| `server-init.sh` | Initializes fresh Ubuntu server with Docker, security, etc. | `./server-init.sh` |
| `setup-ssl.sh` | Obtains and configures SSL certificates | `./setup-ssl.sh cryptoswap.com admin@cryptoswap.com` |
| `deploy.sh` | Deploys application with Docker Compose | `./deploy.sh` |
| `health-check.sh` | Monitors service health | `./health-check.sh --verbose` |

### Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `cswap-dex/.env.production` | Production environment template | Copy to `.env` and configure |
| `cswap-dex/nginx/nginx.conf` | Nginx reverse proxy configuration | Used by Docker container |
| `cswap-dex/docker-compose.yml` | Docker service orchestration | Application root |
| `VULTR_DEPLOYMENT.md` | Complete deployment guide | Documentation |

## 🚀 Quick Start

### 1. Provision Server

```bash
# Set your Vultr API key
export VULTR_API_KEY="your-api-key-here"

# Make scripts executable
chmod +x *.sh

# Provision the server
./vultr-provision.sh
```

**Output:** Server IP address and credentials

### 2. Initialize Server

```bash
# SSH into the new server
ssh root@YOUR_SERVER_IP

# Transfer and run initialization script
# (Upload server-init.sh to the server first)
chmod +x server-init.sh
./server-init.sh
```

**Output:** Fully configured server with Docker, security, and monitoring

### 3. Configure DNS

Point your domain to the server IP:
- **A Record**: `cryptoswap.com` → `YOUR_SERVER_IP`
- **A Record**: `www.cryptoswap.com` → `YOUR_SERVER_IP`

### 4. Setup SSL

```bash
# On the server (as root)
./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
```

**Output:** SSL certificates configured with auto-renewal

### 5. Deploy Application

```bash
# Switch to application user
su - cswap
cd /opt/cswap-dex

# Clone your repository
git clone https://github.com/your-username/cswap-dex.git .

# Configure environment
cp .env.production .env
nano .env  # Update passwords and secrets

# Deploy
./deploy.sh
```

**Output:** Application running with all services healthy

## 📋 Detailed Documentation

For complete step-by-step instructions, see [VULTR_DEPLOYMENT.md](VULTR_DEPLOYMENT.md)

## 🔧 Script Details

### vultr-provision.sh

**Purpose:** Automates server creation on Vultr

**Features:**
- Validates API credentials
- Creates server with specified specs (2 vCPU, 4GB RAM)
- Configures firewall rules
- Waits for server to be ready
- Outputs connection information

**Requirements:**
- `VULTR_API_KEY` environment variable
- `curl` and `jq` installed

**Example:**
```bash
export VULTR_API_KEY="ABC123..."
./vultr-provision.sh
```

### server-init.sh

**Purpose:** Prepares fresh Ubuntu 22.04 server for production

**Features:**
- System updates and essential packages
- Docker and Docker Compose V2 installation
- Certbot for SSL certificates
- UFW firewall configuration
- Fail2Ban for intrusion prevention
- SSH hardening
- Application directories and user setup
- Automatic security updates
- System monitoring tools

**Requirements:**
- Fresh Ubuntu 22.04 server
- Root access

**Example:**
```bash
./server-init.sh
```

### setup-ssl.sh

**Purpose:** Obtains and configures SSL certificates

**Features:**
- Domain validation
- Let's Encrypt certificate generation
- Automatic renewal setup
- Diffie-Hellman parameter generation
- Nginx configuration update
- Certificate verification

**Requirements:**
- Domain DNS must point to server
- Certbot installed
- Ports 80/443 accessible

**Example:**
```bash
./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
```

### deploy.sh

**Purpose:** Deploys application with zero-downtime

**Features:**
- Git repository updates
- Backup before deployment
- Docker image rebuilding
- Container orchestration
- Health checks
- Rollback capability
- Deployment logging

**Options:**
- `--no-pull` - Skip git pull
- `--no-build` - Skip Docker build
- `--skip-health` - Skip health checks
- `--rollback` - Rollback to previous version

**Example:**
```bash
# Standard deployment
./deploy.sh

# Quick restart without rebuild
./deploy.sh --no-pull --no-build

# Rollback
./deploy.sh --rollback
```

### health-check.sh

**Purpose:** Monitors all services and system resources

**Features:**
- Container status monitoring
- HTTP endpoint checks
- Database connectivity tests
- Redis connectivity tests
- SSL certificate validation
- System resource monitoring (CPU, memory, disk)
- Alert notifications
- JSON output for monitoring tools

**Options:**
- `--verbose` or `-v` - Detailed output
- `--quiet` or `-q` - Only show errors
- `--json` - JSON format output
- `--alert` - Send email alerts on failures

**Example:**
```bash
# Basic check
./health-check.sh

# Verbose output
./health-check.sh --verbose

# JSON for monitoring
./health-check.sh --json

# With alerts
./health-check.sh --alert
```

## 🔐 Security Considerations

### Before Deployment

1. **Generate Strong Passwords**
   ```bash
   # Database password
   openssl rand -base64 32
   
   # JWT secrets
   openssl rand -base64 64
   
   # API keys
   openssl rand -hex 32
   ```

2. **Configure Environment Variables**
   - Copy `.env.production` to `.env`
   - Update all values marked with `<CHANGE_THIS>`
   - Set appropriate RPC URLs
   - Configure monitoring endpoints

3. **Review Firewall Rules**
   - Ensure only necessary ports are open
   - Consider restricting SSH access by IP
   - Enable Fail2Ban monitoring

### After Deployment

1. **Disable Password Authentication**
   ```bash
   # Set up SSH keys first, then:
   sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
   sudo systemctl restart sshd
   ```

2. **Regular Updates**
   ```bash
   # System updates (automatic with unattended-upgrades)
   sudo apt-get update && sudo apt-get upgrade -y
   
   # Application updates
   cd /opt/cswap-dex && ./deploy.sh
   ```

3. **Monitor Logs**
   ```bash
   # Application logs
   docker compose logs -f
   
   # Health check logs
   tail -f /var/log/cswap-health.log
   
   # System logs
   tail -f /var/log/syslog
   ```

## 📊 Monitoring

### Automated Monitoring

Set up cron jobs for regular health checks:

```bash
# Edit crontab
crontab -e

# Add these lines:
# Health check every 15 minutes
*/15 * * * * /opt/cswap-dex/health-check.sh --quiet --alert >> /var/log/cswap-health.log 2>&1

# Daily status report
0 9 * * * /opt/cswap-dex/health-check.sh --verbose | mail -s "CSwap Daily Status" admin@cryptoswap.com

# Weekly cleanup
0 2 * * 0 docker system prune -f >> /var/log/docker-cleanup.log 2>&1
```

### Manual Monitoring

```bash
# View service status
cswap-status

# View real-time logs
cswap-logs

# Run health check
./health-check.sh --verbose

# Check Docker resources
docker stats --no-stream

# Check system resources
htop
```

## 🔄 Maintenance Tasks

### Daily
- Monitor health check logs
- Review error logs
- Check system resources

### Weekly
- Review security logs
- Check backup completion
- Test SSL certificate renewal (dry run)
- Clean up Docker resources

### Monthly
- Update system packages
- Review and rotate logs
- Test disaster recovery procedures
- Review and update documentation

## 🆘 Troubleshooting

### Common Issues

**Issue: Script won't run**
```bash
# Make executable
chmod +x script-name.sh

# Check for DOS line endings
dos2unix script-name.sh
```

**Issue: Docker containers won't start**
```bash
# Check logs
docker compose logs

# Rebuild
docker compose up -d --build

# Full restart
docker compose down --remove-orphans
docker system prune -f
docker compose up -d
```

**Issue: SSL certificate errors**
```bash
# Check certificate
openssl x509 -in /etc/letsencrypt/live/cryptoswap.com/fullchain.pem -noout -dates

# Renew manually
sudo certbot renew --force-renewal

# Check nginx config
docker compose exec nginx nginx -t
```

**Issue: Health checks failing**
```bash
# Run verbose check
./health-check.sh --verbose

# Check individual services
curl http://localhost:3000
curl http://localhost:8000/health

# Check containers
docker compose ps
docker compose logs [service-name]
```

## 📞 Support

For detailed troubleshooting, see the [VULTR_DEPLOYMENT.md](VULTR_DEPLOYMENT.md) guide.

## 📝 License

This deployment automation is part of the CSwap DEX project.

---

**Last Updated:** November 2025  
**Maintained By:** CSwap Development Team  
**Documentation Version:** 1.0.0

