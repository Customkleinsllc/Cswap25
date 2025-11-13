/**
 * Token Lists for CryptoSwap DEX
 * Major tokens for each supported chain
 */

import { ChainId } from '@pancakeswap/chains'

export interface Token {
  chainId: number
  address: string
  decimals: number
  symbol: string
  name: string
  logoURI?: string
}

export const ETHEREUM_TOKENS: Token[] = [
  {
    chainId: ChainId.ETHEREUM,
    address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    decimals: 18,
    symbol: 'WETH',
    name: 'Wrapped Ether',
    logoURI: 'https://tokens.1inch.io/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2.png',
  },
  {
    chainId: ChainId.ETHEREUM,
    address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
    decimals: 6,
    symbol: 'USDC',
    name: 'USD Coin',
    logoURI: 'https://tokens.1inch.io/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48.png',
  },
  {
    chainId: ChainId.ETHEREUM,
    address: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
    decimals: 6,
    symbol: 'USDT',
    name: 'Tether USD',
    logoURI: 'https://tokens.1inch.io/0xdac17f958d2ee523a2206206994597c13d831ec7.png',
  },
  {
    chainId: ChainId.ETHEREUM,
    address: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
    decimals: 18,
    symbol: 'DAI',
    name: 'Dai Stablecoin',
    logoURI: 'https://tokens.1inch.io/0x6b175474e89094c44da98b954eedeac495271d0f.png',
  },
  {
    chainId: ChainId.ETHEREUM,
    address: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
    decimals: 8,
    symbol: 'WBTC',
    name: 'Wrapped BTC',
    logoURI: 'https://tokens.1inch.io/0x2260fac5e5542a773aa44fbcfedf7c193bc2c599.png',
  },
]

export const BSC_TOKENS: Token[] = [
  {
    chainId: ChainId.BSC,
    address: '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c',
    decimals: 18,
    symbol: 'WBNB',
    name: 'Wrapped BNB',
    logoURI: 'https://tokens.1inch.io/0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c.png',
  },
  {
    chainId: ChainId.BSC,
    address: '0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d',
    decimals: 18,
    symbol: 'USDC',
    name: 'USD Coin',
    logoURI: 'https://tokens.1inch.io/0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d.png',
  },
  {
    chainId: ChainId.BSC,
    address: '0x55d398326f99059fF775485246999027B3197955',
    decimals: 18,
    symbol: 'USDT',
    name: 'Tether USD',
    logoURI: 'https://tokens.1inch.io/0x55d398326f99059ff775485246999027b3197955.png',
  },
  {
    chainId: ChainId.BSC,
    address: '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56',
    decimals: 18,
    symbol: 'BUSD',
    name: 'Binance USD',
    logoURI: 'https://tokens.1inch.io/0xe9e7cea3dedca5984780bafc599bd69add087d56.png',
  },
  {
    chainId: ChainId.BSC,
    address: '0x2170Ed0880ac9A755fd29B2688956BD959F933F8',
    decimals: 18,
    symbol: 'ETH',
    name: 'Ethereum Token',
    logoURI: 'https://tokens.1inch.io/0x2170ed0880ac9a755fd29b2688956bd959f933f8.png',
  },
]

export const POLYGON_TOKENS: Token[] = [
  {
    chainId: ChainId.POLYGON,
    address: '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270',
    decimals: 18,
    symbol: 'WMATIC',
    name: 'Wrapped Matic',
    logoURI: 'https://tokens.1inch.io/0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270.png',
  },
  {
    chainId: ChainId.POLYGON,
    address: '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174',
    decimals: 6,
    symbol: 'USDC',
    name: 'USD Coin',
    logoURI: 'https://tokens.1inch.io/0x2791bca1f2de4661ed88a30c99a7a9449aa84174.png',
  },
  {
    chainId: ChainId.POLYGON,
    address: '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
    decimals: 6,
    symbol: 'USDT',
    name: 'Tether USD',
    logoURI: 'https://tokens.1inch.io/0xc2132d05d31c914a87c6611c10748aeb04b58e8f.png',
  },
  {
    chainId: ChainId.POLYGON,
    address: '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063',
    decimals: 18,
    symbol: 'DAI',
    name: 'Dai Stablecoin',
    logoURI: 'https://tokens.1inch.io/0x8f3cf7ad23cd3cadbd9735aff958023239c6a063.png',
  },
  {
    chainId: ChainId.POLYGON,
    address: '0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619',
    decimals: 18,
    symbol: 'WETH',
    name: 'Wrapped Ether',
    logoURI: 'https://tokens.1inch.io/0x7ceb23fd6bc0add59e62ac25578270cff1b9f619.png',
  },
]

export const ARBITRUM_TOKENS: Token[] = [
  {
    chainId: ChainId.ARBITRUM,
    address: '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1',
    decimals: 18,
    symbol: 'WETH',
    name: 'Wrapped Ether',
    logoURI: 'https://tokens.1inch.io/0x82af49447d8a07e3bd95bd0d56f35241523fbab1.png',
  },
  {
    chainId: ChainId.ARBITRUM,
    address: '0xaf88d065e77c8cC2239327C5EDb3A432268e5831',
    decimals: 6,
    symbol: 'USDC',
    name: 'USD Coin',
    logoURI: 'https://tokens.1inch.io/0xaf88d065e77c8cc2239327c5edb3a432268e5831.png',
  },
  {
    chainId: ChainId.ARBITRUM,
    address: '0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9',
    decimals: 6,
    symbol: 'USDT',
    name: 'Tether USD',
    logoURI: 'https://tokens.1inch.io/0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9.png',
  },
  {
    chainId: ChainId.ARBITRUM,
    address: '0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1',
    decimals: 18,
    symbol: 'DAI',
    name: 'Dai Stablecoin',
    logoURI: 'https://tokens.1inch.io/0xda10009cbd5d07dd0cecc66161fc93d7c9000da1.png',
  },
  {
    chainId: ChainId.ARBITRUM,
    address: '0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f',
    decimals: 8,
    symbol: 'WBTC',
    name: 'Wrapped BTC',
    logoURI: 'https://tokens.1inch.io/0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f.png',
  },
]

export const AVALANCHE_TOKENS: Token[] = [
  {
    chainId: ChainId.AVALANCHE,
    address: '0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7',
    decimals: 18,
    symbol: 'WAVAX',
    name: 'Wrapped AVAX',
    logoURI: 'https://tokens.1inch.io/0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7.png',
  },
  {
    chainId: ChainId.AVALANCHE,
    address: '0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E',
    decimals: 6,
    symbol: 'USDC',
    name: 'USD Coin',
    logoURI: 'https://tokens.1inch.io/0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e.png',
  },
  {
    chainId: ChainId.AVALANCHE,
    address: '0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7',
    decimals: 6,
    symbol: 'USDT',
    name: 'Tether USD',
    logoURI: 'https://tokens.1inch.io/0x9702230a8ea53601f5cd2dc00fdbc13d4df4a8c7.png',
  },
  {
    chainId: ChainId.AVALANCHE,
    address: '0xd586E7F844cEa2F87f50152665BCbc2C279D8d70',
    decimals: 18,
    symbol: 'DAI',
    name: 'Dai Stablecoin',
    logoURI: 'https://tokens.1inch.io/0xd586e7f844cea2f87f50152665bcbc2c279d8d70.png',
  },
  {
    chainId: ChainId.AVALANCHE,
    address: '0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB',
    decimals: 18,
    symbol: 'WETH',
    name: 'Wrapped Ether',
    logoURI: 'https://tokens.1inch.io/0x49d5c2bdffac6ce2bfdb6640f4f80f226bc10bab.png',
  },
]

// SEI tokens (EVM compatible)
export const SEI_TOKENS: Token[] = [
  {
    chainId: 1329, // SEI chain ID
    address: '0x0000000000000000000000000000000000000000', // Native SEI
    decimals: 18,
    symbol: 'SEI',
    name: 'SEI',
    logoURI: 'https://assets.coingecko.com/coins/images/28205/small/sei.png',
  },
  // Add more SEI tokens as they become available
]

/**
 * Get tokens for a specific chain
 */
export function getTokensByChain(chainId: number): Token[] {
  switch (chainId) {
    case ChainId.ETHEREUM:
      return ETHEREUM_TOKENS
    case ChainId.BSC:
      return BSC_TOKENS
    case ChainId.POLYGON:
      return POLYGON_TOKENS
    case ChainId.ARBITRUM:
      return ARBITRUM_TOKENS
    case ChainId.AVALANCHE:
      return AVALANCHE_TOKENS
    case 1329: // SEI
      return SEI_TOKENS
    default:
      return []
  }
}

/**
 * Get all tokens across all chains
 */
export function getAllTokens(): Token[] {
  return [
    ...ETHEREUM_TOKENS,
    ...BSC_TOKENS,
    ...POLYGON_TOKENS,
    ...ARBITRUM_TOKENS,
    ...AVALANCHE_TOKENS,
    ...SEI_TOKENS,
  ]
}

/**
 * Find a token by address and chain
 */
export function findToken(chainId: number, address: string): Token | undefined {
  const tokens = getTokensByChain(chainId)
  return tokens.find((token) => token.address.toLowerCase() === address.toLowerCase())
}

/**
 * Get native token wrapper address for a chain
 */
export function getNativeWrapperAddress(chainId: number): string | undefined {
  switch (chainId) {
    case ChainId.ETHEREUM:
      return '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2' // WETH
    case ChainId.BSC:
      return '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c' // WBNB
    case ChainId.POLYGON:
      return '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270' // WMATIC
    case ChainId.ARBITRUM:
      return '0x82aF49447D8a07e3bd95BD0d56f35241523fBab1' // WETH
    case ChainId.AVALANCHE:
      return '0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7' // WAVAX
    case 1329: // SEI
      return '0x0000000000000000000000000000000000000000' // Native SEI
    default:
      return undefined
  }
}

/**
 * Check if a token is a stablecoin
 */
export function isStablecoin(symbol: string): boolean {
  const stablecoins = ['USDC', 'USDT', 'DAI', 'BUSD', 'UST', 'FRAX', 'TUSD', 'USDP']
  return stablecoins.includes(symbol.toUpperCase())
}

