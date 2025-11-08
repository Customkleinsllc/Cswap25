import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import { ethers } from 'ethers';
import { logger } from '../utils/logger';

interface Web3ContextType {
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
  isConnected: boolean;
  account: string | null;
  provider: ethers.providers.Web3Provider | null;
  chainId: number | null;
  switchChain: (chainId: number) => Promise<void>;
}

const Web3Context = createContext<Web3ContextType | undefined>(undefined);

export const Web3Provider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isConnected, setIsConnected] = useState(false);
  const [account, setAccount] = useState<string | null>(null);
  const [provider, setProvider] = useState<ethers.providers.Web3Provider | null>(null);
  const [chainId, setChainId] = useState<number | null>(null);

  const connect = useCallback(async () => {
    try {
      if (!window.ethereum) {
        throw new Error('MetaMask not installed');
      }

      // Set timeout for connection
      const connectTimeout = setTimeout(() => {
        throw new Error('Wallet connection timeout');
      }, 15000);

      // Request account access
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });

      if (accounts.length === 0) {
        throw new Error('No accounts found');
      }

      // Create provider
      const web3Provider = new ethers.providers.Web3Provider(window.ethereum);
      const network = await web3Provider.getNetwork();

      setProvider(web3Provider);
      setAccount(accounts[0]);
      setChainId(network.chainId);
      setIsConnected(true);

      clearTimeout(connectTimeout);
      logger.info('Wallet connected successfully', { account: accounts[0], chainId: network.chainId });
    } catch (error) {
      logger.error('Wallet connection failed:', error);
      throw error;
    }
  }, []);

  const disconnect = useCallback(async () => {
    try {
      setProvider(null);
      setAccount(null);
      setChainId(null);
      setIsConnected(false);
      logger.info('Wallet disconnected');
    } catch (error) {
      logger.error('Wallet disconnection failed:', error);
      throw error;
    }
  }, []);

  const switchChain = useCallback(async (targetChainId: number) => {
    try {
      if (!window.ethereum) {
        throw new Error('MetaMask not installed');
      }

      // Set timeout for chain switching
      const switchTimeout = setTimeout(() => {
        throw new Error('Chain switch timeout');
      }, 15000);

      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: `0x${targetChainId.toString(16)}` }],
      });

      clearTimeout(switchTimeout);
      logger.info('Chain switched successfully', { chainId: targetChainId });
    } catch (error) {
      logger.error('Chain switch failed:', error);
      throw error;
    }
  }, []);

  // Listen for account changes
  useEffect(() => {
    if (window.ethereum) {
      const handleAccountsChanged = (accounts: string[]) => {
        if (accounts.length === 0) {
          disconnect();
        } else {
          setAccount(accounts[0]);
        }
      };

      const handleChainChanged = (chainId: string) => {
        setChainId(parseInt(chainId, 16));
        window.location.reload(); // Reload to update UI
      };

      window.ethereum.on('accountsChanged', handleAccountsChanged);
      window.ethereum.on('chainChanged', handleChainChanged);

      return () => {
        window.ethereum.removeListener('accountsChanged', handleAccountsChanged);
        window.ethereum.removeListener('chainChanged', handleChainChanged);
      };
    }
  }, [disconnect]);

  const value: Web3ContextType = {
    connect,
    disconnect,
    isConnected,
    account,
    provider,
    chainId,
    switchChain,
  };

  return <Web3Context.Provider value={value}>{children}</Web3Context.Provider>;
};

export const useWeb3 = (): Web3ContextType => {
  const context = useContext(Web3Context);
  if (context === undefined) {
    throw new Error('useWeb3 must be used within a Web3Provider');
  }
  return context;
};



