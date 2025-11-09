#!/bin/bash
cd /opt/cswap-dex
sed -i 's/async <T>(/async <T,>(/' frontend/src/contexts/TimeoutContext.tsx
echo "Fixed TimeoutContext.tsx"
grep -n "async <T" frontend/src/contexts/TimeoutContext.tsx
docker compose up -d --build --no-cache frontend

