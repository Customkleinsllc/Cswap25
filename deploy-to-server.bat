@echo off
echo === Uploading deployment script ===
scp deploy-all.sh root@149.28.229.49:/opt/cswap-dex/cswap-dex/

echo === Running deployment ===
ssh root@149.28.229.49 "cd /opt/cswap-dex/cswap-dex && chmod +x deploy-all.sh && ./deploy-all.sh"

echo === Deployment complete! ===
echo Open http://149.28.229.49 in your browser
pause

