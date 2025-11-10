import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import timeout from 'connect-timeout';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { CircuitBreaker } from './utils/circuit-breaker';
import { TimeoutError, NetworkError } from './utils/errors';
import { logger } from './utils/logger';
import { poolsRouter } from './routes/pools.js'
import { swapRouter } from './routes/swap.js'
import { adminRouter } from './routes/admin.js'

const app = express();
const PORT = process.env.PORT || 8000;

// Timeout configurations
const TIMEOUTS = {
  API_REQUEST: parseInt(process.env.TIMEOUT_API_REQUEST || '10000'),
  WEB3_CALL: parseInt(process.env.TIMEOUT_WEB3_CALL || '15000'),
  CROSS_CHAIN: parseInt(process.env.TIMEOUT_CROSS_CHAIN || '30000'),
  GRACEFUL_SHUTDOWN: parseInt(process.env.TIMEOUT_GRACEFUL_SHUTDOWN || '30000')
};

// Circuit breaker configurations
const CIRCUIT_BREAKER_CONFIG = {
  threshold: parseInt(process.env.CIRCUIT_BREAKER_THRESHOLD || '3'),
  recoveryTime: parseInt(process.env.CIRCUIT_BREAKER_RECOVERY_TIME || '60000')
};

// Initialize circuit breakers
const priceFeedBreaker = new CircuitBreaker('price-feed', CIRCUIT_BREAKER_CONFIG);
const bridgeBreaker = new CircuitBreaker('bridge', CIRCUIT_BREAKER_CONFIG);

// Middleware with timeout protection
app.use(timeout(TIMEOUTS.API_REQUEST));
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Rate limiting with timeout handling
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn(`Rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({ error: 'Rate limit exceeded' });
  }
});
app.use(limiter);

// API routes
app.use('/api/pools', poolsRouter)
app.use('/api/swap', swapRouter)
app.use('/api/admin', adminRouter)

// Health check endpoint with timeout
app.get('/health', async (req, res) => {
  try {
    const healthCheck = await Promise.race([
      performHealthCheck(),
      new Promise((_, reject) => 
        setTimeout(() => reject(new TimeoutError('Health check timeout')), 5000)
      )
    ]);
    
    res.status(200).json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      ...(typeof healthCheck === 'object' && healthCheck !== null ? healthCheck : {})
    });
  } catch (error) {
    logger.error('Health check failed:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(503).json({
      status: 'unhealthy',
      error: errorMessage,
      timestamp: new Date().toISOString()
    });
  }
});

// Database health check with timeout
app.get('/health/db', async (req, res) => {
  try {
    const dbHealth = await Promise.race([
      checkDatabaseHealth(),
      new Promise((_, reject) => 
        setTimeout(() => reject(new TimeoutError('Database health check timeout')), 5000)
      )
    ]);
    
    res.status(200).json({
      status: 'healthy',
      database: dbHealth,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Database health check failed:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    res.status(503).json({
      status: 'unhealthy',
      error: errorMessage,
      timestamp: new Date().toISOString()
    });
  }
});

// Price feed endpoint with circuit breaker
app.get('/api/price/:token', async (req, res) => {
  try {
    const { token } = req.params;
    
    const price = await priceFeedBreaker.execute(async () => {
      return await Promise.race([
        fetchTokenPrice(token),
        new Promise((_, reject) => 
          setTimeout(() => reject(new TimeoutError('Price fetch timeout')), TIMEOUTS.WEB3_CALL)
        )
      ]);
    });
    
    res.json({ token, price, timestamp: new Date().toISOString() });
  } catch (error) {
    logger.error(`Price fetch failed for token ${req.params.token}:`, error);
    
    if (error instanceof TimeoutError) {
      res.status(408).json({ error: 'Request timeout', token: req.params.token });
    } else if (error instanceof NetworkError) {
      res.status(502).json({ error: 'Network error', token: req.params.token });
    } else {
      res.status(500).json({ error: 'Internal server error', token: req.params.token });
    }
  }
});

// Cross-chain bridge endpoint with circuit breaker
app.post('/api/bridge', async (req, res) => {
  try {
    const { fromChain, toChain, amount, token } = req.body;
    
    const bridgeResult = await bridgeBreaker.execute(async () => {
      return await Promise.race([
        performCrossChainBridge(fromChain, toChain, amount, token),
        new Promise((_, reject) => 
          setTimeout(() => reject(new TimeoutError('Bridge operation timeout')), TIMEOUTS.CROSS_CHAIN)
        )
      ]);
    });
    
    res.json({
      success: true,
      transactionHash: (bridgeResult as {txHash: string; status: string}).txHash,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Bridge operation failed:', error);
    
    if (error instanceof TimeoutError) {
      res.status(408).json({ error: 'Bridge operation timeout' });
    } else {
      res.status(500).json({ error: 'Bridge operation failed' });
    }
  }
});

// Error handling middleware
app.use((error: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  logger.error('Unhandled error:', error);
  
  if (error.code === 'ETIMEDOUT') {
    res.status(408).json({ error: 'Request timeout' });
  } else if (error.name === 'TimeoutError') {
    res.status(408).json({ error: 'Operation timeout' });
  } else {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Graceful shutdown handling
let server: any;
const gracefulShutdown = async (signal: string) => {
  logger.info(`Received ${signal}. Starting graceful shutdown...`);
  
  if (server) {
    server.close(async () => {
      logger.info('HTTP server closed');
      
      try {
        await Promise.race([
          cleanup(),
          new Promise((_, reject) => 
            setTimeout(() => reject(new TimeoutError('Cleanup timeout')), TIMEOUTS.GRACEFUL_SHUTDOWN)
          )
        ]);
        
        logger.info('Graceful shutdown completed');
        process.exit(0);
      } catch (error) {
        logger.error('Cleanup failed:', error);
        process.exit(1);
      }
    });
  }
};

// Signal handlers
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Start server
server = app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
  logger.info(`Timeout configurations:`, TIMEOUTS);
});

// Helper functions
async function performHealthCheck() {
  return {
    memory: process.memoryUsage(),
    cpu: process.cpuUsage(),
    circuitBreakers: {
      priceFeed: priceFeedBreaker.getState(),
      bridge: bridgeBreaker.getState()
    }
  };
}

async function checkDatabaseHealth() {
  // Implement database health check with timeout
  return { status: 'connected', poolSize: 10 };
}

async function fetchTokenPrice(token: string) {
  // Implement token price fetching with timeout
  // This would integrate with Web3 providers
  return { price: 100, currency: 'USD' };
}

async function performCrossChainBridge(fromChain: string, toChain: string, amount: number, token: string) {
  // Implement cross-chain bridge operation with timeout
  return { txHash: '0x123...', status: 'pending' };
}

async function cleanup() {
  // Implement cleanup operations
  logger.info('Performing cleanup operations...');
  
  // Close database connections
  // Close Web3 providers
  // Clear caches
  // etc.
}

export default app;

