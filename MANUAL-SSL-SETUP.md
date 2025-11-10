# Manual SSL Setup Guide for CSwap DEX

## Issue: Plesk is interfering with Nginx

The server is showing Plesk's default page instead of our application. We need to either:
1. Disable Plesk's web server (Apache/Nginx)
2. Configure Plesk to proxy to our Docker containers
3. Use a different port for our application

## Recommended Solution: Use VNC Console to Run Commands

Since SSH is timing out, use the Vultr VNC console:
https://my.vultr.com/subs/vps/novnc/?id=812a1b72-a6c6-4ac2-a2c7-47b8f2c0d334

### Step 1: Check What's Running on Port 80

```bash
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
```

### Step 2: Stop Plesk Web Services

```bash
# Stop Plesk's web server
systemctl stop nginx
systemctl stop httpd
systemctl stop apache2
systemctl disable nginx
systemctl disable httpd
systemctl disable apache2
```

### Step 3: Pull Latest Code

```bash
cd /opt/cswap-dex/cswap-dex
git fetch origin
git reset --hard origin/master
```

### Step 4: Install Certbot

```bash
apt-get update
apt-get install -y certbot
```

### Step 5: Stop Our Nginx Container

```bash
cd /opt/cswap-dex/cswap-dex
docker compose stop nginx
```

### Step 6: Generate SSL Certificates

```bash
certbot certonly --standalone \
  --non-interactive \
  --agree-tos \
  --email admin@cryptoswap.com \
  -d cryptoswap.com \
  -d www.cryptoswap.com \
  --preferred-challenges http \
  --force-renewal
```

**If you get a DNS error**, it means the domain isn't pointing to this IP yet. You can either:
- Update DNS to point cryptoswap.com to 104.238.152.227
- OR use IP-based access (HTTP only)

### Step 7: Verify Certificates Were Created

```bash
ls -la /etc/letsencrypt/live/cryptoswap.com/
```

You should see:
- `fullchain.pem`
- `privkey.pem`
- `chain.pem`

### Step 8: Start All Services

```bash
cd /opt/cswap-dex/cswap-dex
docker compose up -d
```

### Step 9: Check Container Status

```bash
docker compose ps
docker compose logs backend --tail 30
docker compose logs frontend --tail 30
docker compose logs nginx --tail 30
```

### Step 10: Test the Endpoints

```bash
# Test backend
curl http://localhost:8000/health

# Test frontend
curl http://localhost:3000

# Test nginx proxy
curl http://localhost/health

# Test HTTPS (if SSL worked)
curl -k https://localhost/health
```

### Step 11: Check from Browser

Open: http://104.238.152.227

You should see the CSwap DEX application instead of Plesk.

## Alternative: If DNS Isn't Set Up

If cryptoswap.com doesn't point to this server yet, use HTTP-only mode:

```bash
cd /opt/cswap-dex/cswap-dex
cp nginx/nginx-http-only.conf nginx/nginx.conf
docker compose restart nginx
```

## Troubleshooting

### If Plesk Keeps Starting

```bash
# Completely disable Plesk services
systemctl mask nginx
systemctl mask httpd
systemctl mask apache2
```

### If Port 80/443 Are Still Blocked

```bash
# Check what's using the ports
lsof -i :80
lsof -i :443

# Kill the processes if needed
kill -9 <PID>
```

### If Containers Won't Start

```bash
# Check Docker logs
docker compose logs --tail 100

# Rebuild containers
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Check Firewall

```bash
# Make sure ports are open
ufw status
ufw allow 80/tcp
ufw allow 443/tcp
ufw reload
```

## Setup Auto-Renewal for SSL

Once SSL is working:

```bash
# Add renewal cron job
(crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --deploy-hook 'docker compose -f /opt/cswap-dex/cswap-dex/docker-compose.yml restart nginx' >> /var/log/certbot-renewal.log 2>&1") | crontab -
```

## Quick One-Liner (Copy-Paste Ready)

```bash
cd /opt/cswap-dex/cswap-dex && git pull && systemctl stop nginx httpd apache2 2>/dev/null; docker compose down && docker compose build && docker compose up -d && sleep 10 && docker compose ps && docker compose logs nginx --tail 20
```

## Testing Commands

```bash
# Full system check
echo "=== Container Status ===" && docker compose ps && \
echo -e "\n=== Backend Health ===" && curl -s http://localhost:8000/health | jq && \
echo -e "\n=== Nginx Status ===" && curl -I http://localhost 2>&1 | head -5 && \
echo -e "\n=== Application ===" && curl -s http://localhost | head -20
```

