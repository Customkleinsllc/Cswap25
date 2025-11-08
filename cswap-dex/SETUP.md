# CSwap DEX - Setup Guide

## Quick Start

### Prerequisites
- Node.js 18+ and npm 8+
- Git

### Installation

1. **Install root dependencies:**
   ```bash
   npm install
   ```

2. **Install backend dependencies:**
   ```bash
   cd backend
   npm install
   cd ..
   ```

3. **Install frontend dependencies:**
   ```bash
   cd frontend
   npm install
   cd ..
   ```

### Running Locally

#### Option 1: Run Everything Together (from root)
```bash
npm run dev
```

#### Option 2: Run Separately

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```
Backend runs on: http://localhost:8000

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```
Frontend runs on: http://localhost:3000

## Features Implemented

### ✅ Backend Services
- **Avalanche Service** - Integration with Trader Joe on Avalanche network
- **SEI Service** - Integration with Astroport on SEI blockchain
- **Timeout Protection** - All operations have timeout protection (15s for Web3 calls)
- **Circuit Breakers** - Automatic failure detection and recovery
- **Error Handling** - Comprehensive error handling with proper logging

### ✅ API Endpoints

#### Trading
- `POST /api/swap` - Execute token swaps on Avalanche or SEI
- `GET /api/pools` - List all liquidity pools (filter by chain)
- `GET /api/pools/:id` - Get pool details
- `POST /api/pools` - Create new liquidity pools

#### Admin
- `GET /api/admin/stats` - Platform statistics (TVL, volume, users)
- `GET /api/admin/health` - System health check
- `GET /api/admin/transactions` - Recent transactions

### ✅ Frontend Components
- **Trading Interface** - Swap tokens between AVAX and SEI
- **Pool List** - View all liquidity pools with filtering
- **Admin Dashboard** - Complete admin interface with:
  - Statistics tab (TVL, volume, pools, users)
  - Health tab (services, circuit breakers)
  - Transactions tab (recent swap history)

### ✅ Timeout Protection
- All API calls have 5-15 second timeouts
- AbortController used for request cancellation
- Graceful error handling for timeout scenarios
- Circuit breakers prevent cascading failures

## Configuration

### Environment Variables

Create `.env` file in `cswap-dex/` directory:

```bash
# Network Configuration
AVALANCHE_RPC_URL=https://api.avax.network/ext/bc/C/rpc
SEI_RPC_URL=https://sei-rpc.polkachu.com

# Timeout Configurations (milliseconds)
TIMEOUT_API_REQUEST=10000
TIMEOUT_WEB3_CALL=15000
TIMEOUT_CROSS_CHAIN=30000

# Circuit Breaker Configuration
CIRCUIT_BREAKER_THRESHOLD=3
CIRCUIT_BREAKER_RECOVERY_TIME=60000

# Server Configuration
PORT=8000
NODE_ENV=development
```

## Testing

### Test Swap
```bash
curl -X POST http://localhost:8000/api/swap \
  -H "Content-Type: application/json" \
  -d '{
    "tokenIn": "AVAX",
    "tokenOut": "SEI",
    "amountIn": "1",
    "chain": "avalanche"
  }'
```

### Test Pools
```bash
curl http://localhost:8000/api/pools?chain=avalanche
```

### Test Admin Stats
```bash
curl http://localhost:8000/api/admin/stats
```

## Architecture

```
cswap-dex/
├── backend/
│   ├── src/
│   │   ├── services/
│   │   │   ├── avalanche.ts    # Trader Joe integration
│   │   │   └── sei.ts          # Astroport integration
│   │   ├── routes/
│   │   │   ├── pools.ts         # Pool endpoints
│   │   │   ├── swap.ts          # Swap endpoints
│   │   │   └── admin.ts         # Admin endpoints
│   │   ├── utils/
│   │   │   ├── circuit-breaker.ts
│   │   │   ├── errors.ts
│   │   │   └── logger.ts
│   │   ├── app.ts
│   │   └── index.ts
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   │   ├── AdminDashboard.tsx
│   │   │   └── PoolList.tsx
│   │   ├── App.tsx
│   │   └── main.tsx
│   └── package.json
└── package.json
```

## Next Steps

1. **Connect Real Contracts:**
   - Deploy Trader Joe LB contracts on Avalanche testnet
   - Deploy Astroport contracts on SEI testnet
   - Update service implementations with real contract addresses

2. **Add Wallet Integration:**
   - MetaMask for Avalanche
   - WalletConnect for SEI
   - Connect wallet to frontend

3. **Enhanced Features:**
   - Add liquidity functionality
   - Price oracles integration
   - Cross-chain bridge implementation
   - Transaction history database

4. **Production Deployment:**
   - Set up production environment variables
   - Deploy backend to cloud (VPS/Cloud)
   - Deploy frontend to CDN
   - Set up monitoring and alerting

## Troubleshooting

### Backend won't start
- Check Node.js version: `node --version` (should be 18+)
- Clear node_modules and reinstall: `rm -rf node_modules && npm install`

### Frontend build errors
- Check TypeScript version compatibility
- Clear Vite cache: `rm -rf node_modules/.vite`

### Timeout errors
- Increase timeout values in `.env`
- Check network connectivity to RPC endpoints
- Verify RPC URLs are accessible

## Support

For issues or questions, check the code comments or review the implementation in:
- Backend services: `backend/src/services/`
- API routes: `backend/src/routes/`
- Frontend components: `frontend/src/components/`

