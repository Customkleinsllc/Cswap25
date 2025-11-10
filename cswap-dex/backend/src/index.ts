import app, { performCleanup } from './app';
import { logger } from './utils/logger';

const port = parseInt(process.env.PORT || '8000', 10);

const server = app.listen(port, '0.0.0.0', () => {
  logger.info(`Backend server listening on 0.0.0.0:${port}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Backend listening on 0.0.0.0:${port}`);
});

// Graceful shutdown with cleanup
const gracefulShutdown = async (signal: string) => {
  logger.info(`${signal} signal received: starting graceful shutdown`);
  
  server.close(async () => {
    logger.info('HTTP server closed');
    
    try {
      await performCleanup();
      logger.info('Graceful shutdown completed');
      process.exit(0);
    } catch (error) {
      logger.error('Cleanup failed during shutdown:', error);
      process.exit(1);
    }
  });
  
  // Force shutdown after 30 seconds
  setTimeout(() => {
    logger.error('Forced shutdown due to timeout');
    process.exit(1);
  }, 30000);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  server.close(() => process.exit(1));
});
