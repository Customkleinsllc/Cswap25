@echo off
ssh root@104.238.152.227 "docker cp /opt/cswap-dex/frontend/src/index.css cswap-dex-frontend-1:/app/src/index.css"
ssh root@104.238.152.227 "docker cp /opt/cswap-dex/frontend/tailwind.config.js cswap-dex-frontend-1:/app/tailwind.config.js"
ssh root@104.238.152.227 "docker cp /opt/cswap-dex/frontend/postcss.config.js cswap-dex-frontend-1:/app/postcss.config.js"
ssh root@104.238.152.227 "docker cp /opt/cswap-dex/frontend/src/main.tsx cswap-dex-frontend-1:/app/src/main.tsx"
ssh root@104.238.152.227 "docker cp /opt/cswap-dex/frontend/src/App.tsx cswap-dex-frontend-1:/app/src/App.tsx"
echo Files copied to container
pause

