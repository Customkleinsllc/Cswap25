# CSwap DEX - Multi-Chain Decentralized Exchange

A hybrid decentralized exchange supporting SEI, AVAX, and other cryptocurrencies, built on Trader Joe (Avalanche) and Astroport (SEI) architectures.

## 🚀 Features

- **Multi-Chain Support**: Native support for Avalanche (AVAX) and SEI blockchains
- **Cross-Chain Trading**: Bridge functionality between different chains
- **Robust Timeout Handling**: Prevents hanging operations with comprehensive timeout configurations
- **Graceful Error Handling**: Robust error recovery and user feedback
- **High Performance**: Optimized for trading with low latency

## 🏗️ Architecture

### Frontend (React + TypeScript)

- Modern React 18 with TypeScript
- Web3 integration with timeout handling
- Multi-chain wallet support
- Responsive UI with error boundaries

### Backend (Node.js + Express)

- RESTful API with timeout middleware
- Cross-chain bridge service
- Real-time price feeds with circuit breakers
- Database integration with connection pooling

### Smart Contracts

- **Avalanche**: Trader Joe Liquidity Book contracts
- **SEI**: Astroport AMM contracts
- **Bridge**: Cross-chain communication contracts

## 🛠️ Development Setup

### Prerequisites

- Node.js 18+
- Rust 1.68+ (for SEI contracts)
- Git

### Installation

```bash
# Clone and setup
git clone <repository-url>
cd cswap-dex
npm run install:all

# Install Rust (for SEI contracts)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add wasm32-unknown-unknown
```

### Development Commands

```bash
# Start all services with timeout protection
npm run dev

# Start individual services
npm run dev:frontend  # Frontend only
npm run dev:backend   # Backend only

# Build for production
npm run build

# Run tests
npm run test
```

## ⚡ Timeout Configurations

### Network Timeouts

- **API Requests**: 10 seconds
- **Web3 Calls**: 15 seconds
- **Cross-Chain Operations**: 30 seconds
- **Database Queries**: 5 seconds

### Circuit Breakers

- **Price Feed Failures**: 3 consecutive failures trigger circuit breaker
- **Bridge Operations**: 5 consecutive failures trigger circuit breaker
- **Recovery Time**: 60 seconds before retry

### Graceful Shutdown

- **Signal Handling**: SIGTERM, SIGINT support
- **Cleanup Timeout**: 30 seconds for graceful shutdown
- **Resource Cleanup**: Database connections, Web3 providers, file handles

## 🔧 Configuration

### Environment Variables

```bash
# Network Configuration
AVALANCHE_RPC_URL=https://api.avax.network/ext/bc/C/rpc
SEI_RPC_URL=https://sei-rpc.polkachu.com
TIMEOUT_API_REQUEST=10000
TIMEOUT_WEB3_CALL=15000
TIMEOUT_CROSS_CHAIN=30000

# Circuit Breaker Configuration
CIRCUIT_BREAKER_THRESHOLD=3
CIRCUIT_BREAKER_RECOVERY_TIME=60000

# Database Configuration
DB_CONNECTION_TIMEOUT=5000
DB_QUERY_TIMEOUT=5000
DB_POOL_SIZE=10
```

## 🚀 Deployment

### Production Build

```bash
npm run build
```

### Docker Deployment

```bash
docker-compose up -d
```

### Health Checks

- Frontend: `http://localhost:3000/health`
- Backend: `http://localhost:8000/health`
- Database: `http://localhost:8000/health/db`

## 📊 Monitoring

### Metrics

- Request latency and timeout rates
- Circuit breaker activation frequency
- Cross-chain operation success rates
- Database connection pool utilization

### Logging

- Structured logging with correlation IDs
- Error tracking with stack traces
- Performance metrics logging
- Security event logging

## 🔒 Security

- Input validation with timeout protection
- Rate limiting with circuit breakers
- CSRF protection
- XSS prevention
- SQL injection prevention
- Secure Web3 integration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Implement with timeout handling
4. Add tests with timeout scenarios
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details






