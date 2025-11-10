$commands = @'
cd /opt/cswap-dex/cswap-dex
git pull origin master
chmod +x fix-everything.sh enable-https.sh
echo "========================================="
echo "Running comprehensive fix..."
echo "========================================="
./fix-everything.sh
'@

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Running Comprehensive Fixes" -ForegroundColor Cyan  
Write-Host "========================================`n" -ForegroundColor Cyan

ssh root@104.238.152.227 $commands

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "   Fixes Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

