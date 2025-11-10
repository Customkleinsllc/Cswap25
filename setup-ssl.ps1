$commands = @'
cd /opt/cswap-dex/cswap-dex
git pull origin master
apt-get update && apt-get install -y certbot
docker compose stop nginx
certbot certonly --standalone --non-interactive --agree-tos --email admin@cryptoswap.com -d cryptoswap.com -d www.cryptoswap.com --preferred-challenges http --force-renewal
if [ $? -eq 0 ]; then
    echo "SSL certificates generated successfully"
    docker compose up -d
    sleep 10
    docker compose ps
    docker compose logs nginx --tail 20
    echo ""
    echo "Testing HTTPS..."
    curl -k -I https://localhost 2>&1 | head -10
    echo ""
    echo "=== SSL Setup Complete ==="
    echo "Site accessible at: https://cryptoswap.com"
else
    echo "SSL certificate generation failed"
    docker compose start nginx
fi
'@

Write-Host "Connecting to server and setting up SSL..." -ForegroundColor Cyan
ssh root@104.238.152.227 $commands

