import React, { createContext, useContext, useState, useCallback, useRef } from 'react';

interface TimeoutContextType {
  setTimeout: (callback: () => void, delay: number) => number;
  clearTimeout: (id: number) => void;
  setTimeoutAsync: <T>(promise: Promise<T>, delay: number) => Promise<T>;
}

const TimeoutContext = createContext<TimeoutContextType | undefined>(undefined);

export const TimeoutProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [timeouts, setTimeouts] = useState<Map<number, NodeJS.Timeout>>(new Map());
  const timeoutIdRef = useRef(0);

  const setTimeout = useCallback((callback: () => void, delay: number): number => {
    const id = ++timeoutIdRef.current;
    const timeout = global.setTimeout(() => {
      callback();
      setTimeouts(prev => {
        const newTimeouts = new Map(prev);
        newTimeouts.delete(id);
        return newTimeouts;
      });
    }, delay);
    
    setTimeouts(prev => new Map(prev).set(id, timeout));
    return id;
  }, []);

  const clearTimeout = useCallback((id: number) => {
    setTimeouts(prev => {
      const newTimeouts = new Map(prev);
      const timeout = newTimeouts.get(id);
      if (timeout) {
        global.clearTimeout(timeout);
        newTimeouts.delete(id);
      }
      return newTimeouts;
    });
  }, []);

  const setTimeoutAsync = useCallback(async <T>(promise: Promise<T>, delay: number): Promise<T> => {
    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        reject(new Error(`Operation timeout after ${delay}ms`));
      }, delay);

      promise
        .then(result => {
          clearTimeout(timeoutId);
          resolve(result);
        })
        .catch(error => {
          clearTimeout(timeoutId);
          reject(error);
        });
    });
  }, [setTimeout, clearTimeout]);

  // Cleanup all timeouts on unmount
  React.useEffect(() => {
    return () => {
      timeouts.forEach(timeout => global.clearTimeout(timeout));
    };
  }, [timeouts]);

  const value: TimeoutContextType = {
    setTimeout,
    clearTimeout,
    setTimeoutAsync,
  };

  return <TimeoutContext.Provider value={value}>{children}</TimeoutContext.Provider>;
};

export const useTimeout = (): TimeoutContextType => {
  const context = useContext(TimeoutContext);
  if (context === undefined) {
    throw new Error('useTimeout must be used within a TimeoutProvider');
  }
  return context;
};



