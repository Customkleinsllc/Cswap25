@echo off
echo ============================================
echo   CSwap DEX - SSL Certificate Setup
echo ============================================
echo.

echo [1/4] Uploading SSL setup script...
scp setup-ssl-certs.sh root@104.238.152.227:/root/

echo.
echo [2/4] Pulling latest code on server...
ssh root@104.238.152.227 "cd /opt/cswap-dex/cswap-dex && git fetch origin && git reset --hard origin/master"

echo.
echo [3/4] Running SSL certificate setup...
ssh root@104.238.152.227 "chmod +x /root/setup-ssl-certs.sh && /root/setup-ssl-certs.sh"

echo.
echo [4/4] Verifying deployment...
ssh root@104.238.152.227 "docker compose -f /opt/cswap-dex/cswap-dex/docker-compose.yml ps"

echo.
echo ============================================
echo   SSL Setup Complete!
echo ============================================
echo.
echo Your site should now be accessible at:
echo   https://cryptoswap.com
echo   http://cryptoswap.com (redirects to HTTPS)
echo.
pause

