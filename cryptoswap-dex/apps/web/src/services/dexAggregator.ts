import { ChainId } from '@pancakeswap/chains'

export interface QuoteParams {
  fromToken: string
  toToken: string
  amount: string
  chainId: number
  userAddress: string
  slippage: number
}

export interface Quote {
  fromToken: string
  toToken: string
  fromAmount: string
  toAmount: string
  protocols: Array<Array<Array<{ name: string; part: number }>>>
  estimatedGas: string
  tx: {
    from: string
    to: string
    data: string
    value: string
    gas: string
    gasPrice: string
  }
}

/**
 * DEX Aggregator Service
 * Integrates with 1inch API to get best swap routes across multiple DEXes
 */
export class DexAggregator {
  private apiKey: string
  private apiBaseUrl = 'https://api.1inch.dev/swap/v5.2'

  constructor(apiKey: string) {
    this.apiKey = apiKey
  }

  /**
   * Map CryptoSwap chain IDs to 1inch chain IDs
   */
  private getOneInchChainId(chainId: number): number {
    const chainMap: Record<number, number> = {
      [ChainId.ETHEREUM]: 1,
      [ChainId.BSC]: 56,
      [ChainId.POLYGON]: 137,
      [ChainId.ARBITRUM_ONE]: 42161,
      [ChainId.AVALANCHE]: 43114,
      // Add more chains as supported by 1inch
    }

    const oneInchChainId = chainMap[chainId]
    if (!oneInchChainId) {
      throw new Error(`Chain ${chainId} is not supported by 1inch aggregator`)
    }

    return oneInchChainId
  }

  /**
   * Get a quote for the best swap route without executing
   */
  async getQuote(params: Omit<QuoteParams, 'userAddress'>): Promise<Omit<Quote, 'tx'>> {
    try {
      const chain = this.getOneInchChainId(params.chainId)
      const url = `${this.apiBaseUrl}/${chain}/quote`

      const queryParams = new URLSearchParams({
        src: params.fromToken,
        dst: params.toToken,
        amount: params.amount,
      })

      const response = await fetch(`${url}?${queryParams.toString()}`, {
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          accept: 'application/json',
        },
      })

      if (!response.ok) {
        const error = await response.json()
        throw new Error(`1inch API error: ${error.description || response.statusText}`)
      }

      const data = await response.json()

      return {
        fromToken: params.fromToken,
        toToken: params.toToken,
        fromAmount: params.amount,
        toAmount: data.toAmount,
        protocols: data.protocols || [],
        estimatedGas: data.estimatedGas || '0',
      }
    } catch (error) {
      console.error('Error getting quote from 1inch:', error)
      throw error
    }
  }

  /**
   * Get the best swap route and transaction data for execution
   */
  async getBestQuote(params: QuoteParams): Promise<Quote> {
    try {
      const chain = this.getOneInchChainId(params.chainId)
      const url = `${this.apiBaseUrl}/${chain}/swap`

      const queryParams = new URLSearchParams({
        src: params.fromToken,
        dst: params.toToken,
        amount: params.amount,
        from: params.userAddress,
        slippage: params.slippage.toString(),
        disableEstimate: 'false',
        allowPartialFill: 'false',
      })

      // Add platform fee if configured
      const platformFeeReceiver = process.env.NEXT_PUBLIC_REVENUE_WALLET_EVM
      const platformFeeBps = process.env.NEXT_PUBLIC_PLATFORM_FEE_BPS || '0'
      
      if (platformFeeReceiver && platformFeeBps !== '0') {
        queryParams.append('referrer', platformFeeReceiver)
        queryParams.append('fee', platformFeeBps)
      }

      const response = await fetch(`${url}?${queryParams.toString()}`, {
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          accept: 'application/json',
        },
      })

      if (!response.ok) {
        const error = await response.json()
        throw new Error(`1inch API error: ${error.description || response.statusText}`)
      }

      const data = await response.json()

      return {
        fromToken: params.fromToken,
        toToken: params.toToken,
        fromAmount: params.amount,
        toAmount: data.toAmount,
        protocols: data.protocols || [],
        estimatedGas: data.tx.gas,
        tx: {
          from: data.tx.from,
          to: data.tx.to,
          data: data.tx.data,
          value: data.tx.value,
          gas: data.tx.gas,
          gasPrice: data.tx.gasPrice,
        },
      }
    } catch (error) {
      console.error('Error getting swap quote from 1inch:', error)
      throw error
    }
  }

  /**
   * Get supported tokens for a specific chain
   */
  async getSupportedTokens(chainId: number) {
    try {
      const chain = this.getOneInchChainId(chainId)
      const url = `${this.apiBaseUrl}/${chain}/tokens`

      const response = await fetch(url, {
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          accept: 'application/json',
        },
      })

      if (!response.ok) {
        throw new Error(`Failed to get supported tokens: ${response.statusText}`)
      }

      const data = await response.json()
      return data.tokens
    } catch (error) {
      console.error('Error getting supported tokens:', error)
      throw error
    }
  }

  /**
   * Health check for the aggregator service
   */
  async healthCheck(chainId: number): Promise<boolean> {
    try {
      const chain = this.getOneInchChainId(chainId)
      const url = `${this.apiBaseUrl}/${chain}/healthcheck`

      const response = await fetch(url, {
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
        },
      })

      return response.ok
    } catch (error) {
      console.error('Health check failed:', error)
      return false
    }
  }
}

// Export singleton instance
let aggregatorInstance: DexAggregator | null = null

export function getDexAggregator(): DexAggregator {
  if (!aggregatorInstance) {
    const apiKey = process.env.NEXT_PUBLIC_1INCH_API_KEY
    if (!apiKey) {
      throw new Error('1inch API key not configured. Set NEXT_PUBLIC_1INCH_API_KEY in your environment.')
    }
    aggregatorInstance = new DexAggregator(apiKey)
  }
  return aggregatorInstance
}

export const dexAggregator = {
  getInstance: getDexAggregator,
}

