# CSwap DEX - Vultr Deployment Guide

Complete step-by-step guide for deploying the CSwap DEX Exchange on Vultr infrastructure.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Obtaining a Vultr API Key](#obtaining-a-vultr-api-key)
3. [Server Provisioning](#server-provisioning)
4. [DNS Configuration](#dns-configuration)
5. [Server Initialization](#server-initialization)
6. [Application Deployment](#application-deployment)
7. [SSL Certificate Setup](#ssl-certificate-setup)
8. [Health Monitoring](#health-monitoring)
9. [Maintenance](#maintenance)
10. [Troubleshooting](#troubleshooting)
11. [Rollback Procedures](#rollback-procedures)

---

## Prerequisites

Before starting the deployment, ensure you have:

- **Vultr Account**: Sign up at [https://vultr.com](https://vultr.com)
- **Domain Name**: `cryptoswap.com` registered and accessible
- **Git Repository**: Your CSwap DEX code in a Git repository
- **Local Machine**: Linux, macOS, or Windows with WSL
- **Required Tools**:
  - `curl` - for API calls
  - `jq` - for JSON parsing
  - `ssh` - for server access
  - `git` - for version control

### Installing Required Tools

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y curl jq git openssh-client
```

**macOS:**
```bash
brew install curl jq git
```

**Windows (WSL):**
```bash
sudo apt-get update
sudo apt-get install -y curl jq git openssh-client
```

---

## Obtaining a Vultr API Key

1. **Log in to Vultr Dashboard**
   - Go to [https://my.vultr.com](https://my.vultr.com)
   - Sign in with your credentials

2. **Navigate to API Settings**
   - Click on your account name (top right)
   - Select "Account" → "API"
   - Or go directly to: [https://my.vultr.com/settings/#settingsapi](https://my.vultr.com/settings/#settingsapi)

3. **Generate API Key**
   - Click "Enable API"
   - Add access control (optional but recommended):
     - Enter your public IP address
     - This restricts API access to your IP only
   - Copy the API key and save it securely

4. **Set Environment Variable**
   ```bash
   export VULTR_API_KEY="your-api-key-here"
   ```

5. **Make it Persistent** (optional)
   ```bash
   echo 'export VULTR_API_KEY="your-api-key-here"' >> ~/.bashrc
   source ~/.bashrc
   ```

---

## Server Provisioning

### Step 1: Run the Provisioning Script

```bash
# Make the script executable
chmod +x vultr-provision.sh

# Run the provisioning script
./vultr-provision.sh
```

The script will:
- ✓ Verify your API key
- ✓ Check plan and region availability
- ✓ Create firewall rules
- ✓ Provision the server (2 vCPU, 4GB RAM, Seattle)
- ✓ Wait for the server to be ready
- ✓ Display server information

### Step 2: Save Server Information

The script outputs important information:

```
Server Details:
  Instance ID: xxxxx-xxxx-xxxx-xxxx-xxxxxxxxx
  IP Address: 123.45.67.89
  Default Password: xxxxxxxxxx
```

**Save this information securely!**

The server details are also saved to `vultr-server-info.json`.

### Step 3: Test SSH Connection

```bash
# Replace with your server IP
ssh root@123.45.67.89

# Enter the default password when prompted
```

If connection is successful, you'll see the Ubuntu welcome message.

---

## DNS Configuration

Configure your domain to point to the new server.

### Step 1: Get Server IP Address

From the provisioning output or:
```bash
cat vultr-server-info.json | jq -r '.main_ip'
```

### Step 2: Configure DNS Records

Log in to your domain registrar (e.g., GoDaddy, Namecheap, Cloudflare) and add:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 123.45.67.89 | 3600 |
| A | www | 123.45.67.89 | 3600 |

**Important:** Replace `123.45.67.89` with your actual server IP.

### Step 3: Verify DNS Propagation

```bash
# Check DNS resolution
dig cryptoswap.com +short
dig www.cryptoswap.com +short

# Both should return your server IP
```

DNS propagation can take 5 minutes to 48 hours. You can proceed with server setup while waiting.

---

## Server Initialization

### Step 1: Connect to Server

```bash
ssh root@123.45.67.89
# Or if DNS is configured:
ssh root@cryptoswap.com
```

### Step 2: Transfer Initialization Script

**Option A: Upload from local machine**
```bash
# From your local machine
scp server-init.sh root@123.45.67.89:/root/
```

**Option B: Download from repository**
```bash
# On the server
curl -O https://raw.githubusercontent.com/your-repo/cswap-dex/main/server-init.sh
```

**Option C: Copy and paste**
```bash
# On the server
nano server-init.sh
# Paste the script content
# Save with Ctrl+X, Y, Enter
```

### Step 3: Run Initialization Script

```bash
# Make executable
chmod +x server-init.sh

# Run the script
./server-init.sh
```

The script will (takes 5-10 minutes):
- ✓ Update system packages
- ✓ Install Docker and Docker Compose V2
- ✓ Install Certbot
- ✓ Configure UFW firewall
- ✓ Set up Fail2Ban
- ✓ Create application user and directories
- ✓ Configure SSH hardening
- ✓ Set up automatic security updates
- ✓ Install monitoring tools

### Step 4: Verify Installation

```bash
# Check Docker
docker --version
docker compose version

# Check Certbot
certbot --version

# Check firewall
sudo ufw status

# Check application directory
ls -la /opt/cswap-dex
```

---

## Application Deployment

### Step 1: Switch to Application User

```bash
su - cswap
cd /opt/cswap-dex
```

### Step 2: Clone Repository

```bash
# Clone your repository
git clone https://github.com/your-username/cswap-dex.git .

# Or if using SSH keys:
git clone git@github.com:your-username/cswap-dex.git .
```

### Step 3: Configure Environment Variables

```bash
# Copy production template
cp .env.production .env

# Edit environment file
nano .env
```

**Required Changes:**
```bash
# Database
POSTGRES_PASSWORD=<generate-strong-password>

# Redis
REDIS_PASSWORD=<generate-strong-password>

# Security
JWT_SECRET=<generate-secret>
JWT_REFRESH_SECRET=<generate-secret>
SESSION_SECRET=<generate-secret>
API_KEY_SALT=<generate-salt>
INTERNAL_API_KEY=<generate-key>
```

**Generate Secure Values:**
```bash
# Generate passwords and secrets
openssl rand -base64 32  # For passwords
openssl rand -base64 64  # For JWT secrets
openssl rand -hex 32     # For API keys
```

### Step 4: Update Docker Compose for Production

Edit `docker-compose.yml` to add SSL volume mount:

```bash
nano docker-compose.yml
```

Add to nginx service volumes:
```yaml
volumes:
  - ./nginx/nginx.conf:/etc/nginx/nginx.conf
  - /etc/letsencrypt:/etc/letsencrypt:ro  # Add this line
```

### Step 5: Transfer Deployment Scripts

```bash
# Make all scripts executable
chmod +x deploy.sh setup-ssl.sh health-check.sh
```

---

## SSL Certificate Setup

### Step 1: Ensure DNS is Propagated

```bash
# Verify DNS resolution
dig cryptoswap.com +short
# Should return your server IP
```

### Step 2: Run SSL Setup Script

```bash
# Switch to root user
exit  # Exit from cswap user
# Or use: sudo su -

# Run SSL setup
./setup-ssl.sh cryptoswap.com admin@cryptoswap.com
```

The script will:
- ✓ Validate domain resolution
- ✓ Obtain Let's Encrypt SSL certificate
- ✓ Generate Diffie-Hellman parameters
- ✓ Set up automatic renewal
- ✓ Configure nginx for SSL

### Step 3: Verify SSL Certificate

```bash
# Check certificate files
ls -la /etc/letsencrypt/live/cryptoswap.com/

# Check certificate expiration
openssl x509 -in /etc/letsencrypt/live/cryptoswap.com/fullchain.pem -noout -dates

# Test renewal (dry run)
certbot renew --dry-run
```

---

## Initial Application Deployment

### Step 1: Deploy Application

```bash
# Switch to application user
su - cswap
cd /opt/cswap-dex

# Run deployment
./deploy.sh
```

The deployment script will:
- ✓ Stop existing containers
- ✓ Clean Docker resources
- ✓ Build Docker images
- ✓ Start all services
- ✓ Run health checks
- ✓ Display status

### Step 2: Monitor Deployment

```bash
# Watch container status
watch docker compose ps

# View logs
docker compose logs -f

# Check specific service
docker compose logs -f backend
docker compose logs -f frontend
```

### Step 3: Verify Services

```bash
# Check frontend
curl http://localhost:3000

# Check backend API
curl http://localhost:8000/health

# Check HTTPS
curl https://cryptoswap.com

# Run full health check
./health-check.sh --verbose
```

---

## Health Monitoring

### Manual Health Checks

```bash
# Basic health check
./health-check.sh

# Verbose output
./health-check.sh --verbose

# JSON output (for monitoring tools)
./health-check.sh --json

# With email alerts
./health-check.sh --alert
```

### Automated Monitoring

**Set up cron job for regular health checks:**

```bash
# Edit crontab
crontab -e

# Add health check every 15 minutes
*/15 * * * * /opt/cswap-dex/health-check.sh --quiet --alert >> /var/log/cswap-health.log 2>&1

# Add daily status report
0 9 * * * /opt/cswap-dex/health-check.sh --verbose | mail -s "CSwap Daily Status" admin@cryptoswap.com
```

### Helper Commands

```bash
# View service status and stats
cswap-status

# View real-time logs
cswap-logs

# Clean up Docker resources
docker-cleanup
```

---

## Maintenance

### Updating the Application

```bash
# Switch to application user
su - cswap
cd /opt/cswap-dex

# Deploy latest changes
./deploy.sh
```

### Database Backup

```bash
# Manual backup
docker exec postgres pg_dump -U cswap_user cswap_dex | gzip > /opt/cswap-dex/backups/db_$(date +%Y%m%d_%H%M%S).sql.gz

# Restore from backup
gunzip -c backup.sql.gz | docker exec -i postgres psql -U cswap_user -d cswap_dex
```

### Certificate Renewal

Certificates renew automatically, but you can manually renew:

```bash
# Manual renewal
certbot renew

# With container restart
certbot renew --pre-hook "docker compose -f /opt/cswap-dex/docker-compose.yml stop nginx" --post-hook "docker compose -f /opt/cswap-dex/docker-compose.yml start nginx"
```

### System Updates

```bash
# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Reboot if required
sudo reboot
```

---

## Troubleshooting

### Container Issues

**Problem: Container won't start**
```bash
# Check logs
docker compose logs <container-name>

# Check container details
docker inspect <container-name>

# Restart specific service
docker compose restart <container-name>

# Rebuild and restart
docker compose up -d --build <container-name>
```

**Problem: Container is unhealthy**
```bash
# Check health status
docker inspect --format='{{json .State.Health}}' <container-name> | jq

# View logs
docker compose logs -f <container-name>
```

### Network Issues

**Problem: Cannot access the application**
```bash
# Check firewall
sudo ufw status

# Check if ports are open
sudo netstat -tulpn | grep -E ':(80|443|3000|8000)'

# Check nginx status
docker compose ps nginx

# Test local connectivity
curl -I http://localhost:3000
curl -I http://localhost:8000/health
```

**Problem: SSL certificate issues**
```bash
# Check certificate
openssl s_client -servername cryptoswap.com -connect cryptoswap.com:443

# Renew certificate
sudo certbot renew --force-renewal

# Check nginx config
docker compose exec nginx nginx -t
```

### Database Issues

**Problem: Database connection errors**
```bash
# Check database status
docker compose ps postgres

# Test connection
docker exec postgres pg_isready -U cswap_user

# View database logs
docker compose logs postgres

# Connect to database
docker exec -it postgres psql -U cswap_user -d cswap_dex
```

### Performance Issues

**Problem: High CPU/memory usage**
```bash
# Check resource usage
docker stats

# Check system resources
htop

# Check disk space
df -h

# Clean up Docker resources
docker system prune -af
```

---

## Rollback Procedures

### Automatic Rollback

If deployment fails, the deployment script offers automatic rollback:
```bash
./deploy.sh
# If health checks fail, script will ask:
# "Do you want to rollback? (y/n)"
```

### Manual Rollback

**Option 1: Rollback to previous commit**
```bash
cd /opt/cswap-dex

# View commit history
git log --oneline -10

# Rollback to specific commit
git checkout <commit-hash>

# Deploy
./deploy.sh --no-pull
```

**Option 2: Restore from backup**
```bash
# List backups
ls -lh /opt/cswap-dex/backups/

# Restore environment
cp /opt/cswap-dex/backups/.env.20240101_120000 .env

# Restore database
gunzip -c /opt/cswap-dex/backups/db_20240101_120000.sql.gz | docker exec -i postgres psql -U cswap_user -d cswap_dex

# Restart services
docker compose restart
```

**Option 3: Complete redeployment**
```bash
# Stop all services
docker compose down --remove-orphans

# Clean Docker
docker system prune -af

# Pull specific version
git checkout v1.0.0

# Deploy
./deploy.sh
```

---

## Security Best Practices

1. **Change Default Passwords**: Update all passwords in `.env` file
2. **SSH Key Authentication**: Set up SSH keys and disable password auth
3. **Regular Updates**: Keep system and packages updated
4. **Firewall Rules**: Use UFW to restrict access
5. **Fail2Ban**: Monitor and block suspicious activity
6. **SSL Certificates**: Keep certificates up to date
7. **Backup Strategy**: Regular automated backups
8. **Monitoring**: Set up alerts for critical issues
9. **Access Control**: Limit who has server access
10. **Audit Logs**: Regularly review logs for suspicious activity

---

## Additional Resources

### Useful Commands

```bash
# View all running containers
docker compose ps

# View container logs
docker compose logs -f [service-name]

# Restart all services
docker compose restart

# Stop all services
docker compose down

# Rebuild specific service
docker compose up -d --build [service-name]

# Execute command in container
docker compose exec [service-name] [command]

# View Docker stats
docker stats --no-stream

# Clean up unused Docker resources
docker system prune -af --volumes
```

### Log Locations

- **Application logs**: `/opt/cswap-dex/logs/`
- **Nginx logs**: `/var/log/nginx/`
- **System logs**: `/var/log/syslog`
- **Docker logs**: `docker compose logs`
- **Health check logs**: `/var/log/cswap-health.log`
- **Deployment logs**: `/opt/cswap-dex/logs/deployment.log`

### Support and Documentation

- **Vultr Documentation**: [https://www.vultr.com/docs/](https://www.vultr.com/docs/)
- **Docker Documentation**: [https://docs.docker.com/](https://docs.docker.com/)
- **Let's Encrypt Documentation**: [https://letsencrypt.org/docs/](https://letsencrypt.org/docs/)
- **Nginx Documentation**: [https://nginx.org/en/docs/](https://nginx.org/en/docs/)

---

## Quick Reference

### Server Information
- **Server Location**: US West (Seattle)
- **Plan**: 2 vCPU, 4GB RAM, 80GB SSD
- **OS**: Ubuntu 22.04 LTS
- **Domain**: cryptoswap.com

### Ports
- **22**: SSH
- **80**: HTTP (redirects to HTTPS)
- **443**: HTTPS
- **3000**: Frontend (internal)
- **8000**: Backend API (internal)
- **5432**: PostgreSQL (internal)
- **6379**: Redis (internal)

### Important Directories
- **Application**: `/opt/cswap-dex/`
- **Logs**: `/opt/cswap-dex/logs/`
- **Backups**: `/opt/cswap-dex/backups/`
- **SSL Certificates**: `/etc/letsencrypt/live/cryptoswap.com/`

### Key Files
- **Environment**: `/opt/cswap-dex/.env`
- **Docker Compose**: `/opt/cswap-dex/docker-compose.yml`
- **Nginx Config**: `/opt/cswap-dex/nginx/nginx.conf`

---

## Deployment Checklist

- [ ] Vultr account created
- [ ] API key obtained and tested
- [ ] Server provisioned successfully
- [ ] DNS configured and propagated
- [ ] Server initialization completed
- [ ] Docker and Docker Compose installed
- [ ] SSL certificates obtained
- [ ] Environment variables configured
- [ ] Application code deployed
- [ ] All containers running and healthy
- [ ] HTTPS working correctly
- [ ] Health monitoring set up
- [ ] Backup strategy implemented
- [ ] Documentation reviewed
- [ ] Team notified of deployment

---

## Getting Help

If you encounter issues:

1. **Check logs**: Review application and system logs
2. **Run health check**: `./health-check.sh --verbose`
3. **Review this guide**: Double-check all steps
4. **Check system resources**: Ensure adequate CPU/memory/disk
5. **Search documentation**: Vultr, Docker, nginx docs
6. **Contact support**: Vultr support or your DevOps team

---

**Congratulations!** Your CSwap DEX Exchange is now deployed on Vultr! 🚀

For ongoing maintenance and updates, refer to the [Maintenance](#maintenance) section of this guide.

