$server = "root@104.238.152.227"

Write-Host "Checking frontend container status..."
ssh $server "docker ps -a | grep frontend"

Write-Host "`nChecking if frontend image exists..."
ssh $server "docker images | grep frontend"

Write-Host "`nAttempting to build and start frontend..."
ssh $server "cd /opt/cswap-dex && docker compose build frontend 2>&1 | tail -50"

Write-Host "`nStarting frontend..."
ssh $server "cd /opt/cswap-dex && docker compose up -d frontend"

Write-Host "`nWaiting 20 seconds..."
Start-Sleep -Seconds 20

Write-Host "`nChecking frontend status after start..."
ssh $server "docker ps | grep frontend"

Write-Host "`nChecking frontend logs..."
ssh $server "docker logs cswap-dex-frontend-1 --tail 30 2>&1"

