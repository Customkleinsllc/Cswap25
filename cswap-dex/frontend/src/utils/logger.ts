// Simple logger utility for the CSwap DEX frontend

export const logger = {
  info: (message: string, data?: any) => {
    console.log(`[INFO] ${message}`, data || '');
  },
  
  error: (message: string, error?: any) => {
    console.error(`[ERROR] ${message}`, error || '');
  },
  
  warning: (message: string, data?: any) => {
    console.warn(`[WARN] ${message}`, data || '');
  },
  
  debug: (message: string, data?: any) => {
    if (process.env.NODE_ENV === 'development') {
      console.debug(`[DEBUG] ${message}`, data || '');
    }
  }
};

