$commands = @'
cd /opt/cswap-dex/cswap-dex
docker compose stop nginx
certbot certonly --standalone --non-interactive --agree-tos --email admin@cryptoswap.com -d cryptoswap.com -d www.cryptoswap.com --preferred-challenges http --force-renewal && echo "SSL certificates generated!" || echo "SSL failed - check if DNS points to this IP"
docker compose up -d
sleep 10
docker compose ps
echo ""
echo "Testing endpoints..."
curl -I http://localhost/health 2>&1 | head -5
'@

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Completing SSL Certificate Setup" -ForegroundColor Cyan  
Write-Host "========================================`n" -ForegroundColor Cyan

ssh root@104.238.152.227 $commands

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "   Setup Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green
Write-Host "Check your site at: http://104.238.152.227`n" -ForegroundColor Yellow

