@echo off
echo === Uploading deployment script ===
scp deploy-all.sh root@104.238.152.227:/opt/cswap-dex/cswap-dex/

echo === Running deployment ===
ssh root@104.238.152.227 "cd /opt/cswap-dex/cswap-dex && chmod +x deploy-all.sh && ./deploy-all.sh"

echo === Deployment complete! ===
echo Open http://104.238.152.227 in your browser
pause

