import { ChainId } from '@pancakeswap/chains'

export interface AggregatedFarm {
  id: string
  protocol: string
  chain: string
  pool: string
  symbol: string
  apy: number
  apyBase: number
  apyReward: number
  tvlUsd: number
  volumeUsd24h: number
  url: string
  rewardTokens: string[]
}

export interface FarmFilters {
  chainId?: number
  minApy?: number
  minTvl?: number
  protocols?: string[]
  limit?: number
}

/**
 * Farm Aggregator Service
 * Fetches yield farming opportunities from DeFi Llama API
 */
export class FarmAggregator {
  private apiBaseUrl = 'https://yields.llama.fi'
  private cacheKey = 'cryptoswap_farms_cache'
  private cacheDuration = 5 * 60 * 1000 // 5 minutes

  /**
   * Map CryptoSwap chain IDs to DeFi Llama chain names
   */
  private getDefiLlamaChainName(chainId: number): string {
    const chainMap: Record<number, string> = {
      [ChainId.ETHEREUM]: 'Ethereum',
      [ChainId.BSC]: 'BSC',
      [ChainId.POLYGON]: 'Polygon',
      [ChainId.ARBITRUM_ONE]: 'Arbitrum',
      [ChainId.AVALANCHE]: 'Avalanche',
      [ChainId.BASE]: 'Base',
      [ChainId.LINEA]: 'Linea',
      [ChainId.ZKSYNC]: 'zkSync Era',
      [ChainId.OPBNB]: 'opBNB',
    }

    return chainMap[chainId] || 'Unknown'
  }

  /**
   * Fetch all farms from cache or API
   */
  private async fetchAllFarms(): Promise<any[]> {
    try {
      // Check cache first
      if (typeof window !== 'undefined') {
        const cached = localStorage.getItem(this.cacheKey)
        if (cached) {
          const { data, timestamp } = JSON.parse(cached)
          if (Date.now() - timestamp < this.cacheDuration) {
            return data
          }
        }
      }

      // Fetch from API
      const response = await fetch(`${this.apiBaseUrl}/pools`)
      
      if (!response.ok) {
        throw new Error(`DeFi Llama API error: ${response.statusText}`)
      }

      const result = await response.json()
      const farms = result.data || []

      // Cache the result
      if (typeof window !== 'undefined') {
        localStorage.setItem(
          this.cacheKey,
          JSON.stringify({
            data: farms,
            timestamp: Date.now(),
          })
        )
      }

      return farms
    } catch (error) {
      console.error('Error fetching farms from DeFi Llama:', error)
      throw error
    }
  }

  /**
   * Get aggregated farms filtered by criteria
   */
  async getAggregatedFarms(filters: FarmFilters = {}): Promise<AggregatedFarm[]> {
    try {
      const allFarms = await this.fetchAllFarms()

      let filteredFarms = allFarms

      // Filter by chain
      if (filters.chainId) {
        const chainName = this.getDefiLlamaChainName(filters.chainId)
        filteredFarms = filteredFarms.filter((farm) => farm.chain === chainName)
      }

      // Filter by minimum APY
      if (filters.minApy !== undefined) {
        filteredFarms = filteredFarms.filter((farm) => farm.apy && farm.apy >= filters.minApy!)
      }

      // Filter by minimum TVL
      if (filters.minTvl !== undefined) {
        filteredFarms = filteredFarms.filter((farm) => farm.tvlUsd && farm.tvlUsd >= filters.minTvl!)
      }

      // Filter by protocols
      if (filters.protocols && filters.protocols.length > 0) {
        filteredFarms = filteredFarms.filter((farm) => filters.protocols!.includes(farm.project))
      }

      // Filter out pools with no APY or invalid data
      filteredFarms = filteredFarms.filter(
        (farm) => farm.apy > 0 && farm.tvlUsd > 0 && !farm.ilRisk && farm.exposure !== 'single'
      )

      // Sort by APY (highest first)
      filteredFarms.sort((a, b) => (b.apy || 0) - (a.apy || 0))

      // Apply limit
      const limit = filters.limit || 50
      filteredFarms = filteredFarms.slice(0, limit)

      // Transform to our format
      return filteredFarms.map((farm) => ({
        id: farm.pool,
        protocol: farm.project,
        chain: farm.chain,
        pool: farm.pool,
        symbol: farm.symbol,
        apy: farm.apy || 0,
        apyBase: farm.apyBase || 0,
        apyReward: farm.apyReward || 0,
        tvlUsd: farm.tvlUsd || 0,
        volumeUsd24h: farm.volumeUsd1d || 0,
        url: farm.poolMeta || `https://defillama.com/yields/pool/${farm.pool}`,
        rewardTokens: farm.rewardTokens || [],
      }))
    } catch (error) {
      console.error('Error getting aggregated farms:', error)
      return []
    }
  }

  /**
   * Get farms for a specific protocol
   */
  async getFarmsByProtocol(protocol: string, chainId?: number): Promise<AggregatedFarm[]> {
    return this.getAggregatedFarms({
      protocols: [protocol],
      chainId,
      limit: 100,
    })
  }

  /**
   * Get top farms across all chains
   */
  async getTopFarms(limit = 20): Promise<AggregatedFarm[]> {
    return this.getAggregatedFarms({
      minApy: 5,
      minTvl: 100000,
      limit,
    })
  }

  /**
   * Get farm statistics for a chain
   */
  async getChainStats(chainId: number) {
    try {
      const farms = await this.getAggregatedFarms({ chainId, limit: 1000 })

      const totalTvl = farms.reduce((sum, farm) => sum + farm.tvlUsd, 0)
      const avgApy = farms.reduce((sum, farm) => sum + farm.apy, 0) / farms.length
      const protocols = [...new Set(farms.map((f) => f.protocol))].length

      return {
        totalFarms: farms.length,
        totalTvl,
        avgApy,
        protocols,
        topFarm: farms[0],
      }
    } catch (error) {
      console.error('Error getting chain stats:', error)
      return null
    }
  }

  /**
   * Clear the farms cache
   */
  clearCache() {
    if (typeof window !== 'undefined') {
      localStorage.removeItem(this.cacheKey)
    }
  }
}

// Export singleton instance
let aggregatorInstance: FarmAggregator | null = null

export function getFarmAggregator(): FarmAggregator {
  if (!aggregatorInstance) {
    aggregatorInstance = new FarmAggregator()
  }
  return aggregatorInstance
}

export const farmAggregator = {
  getInstance: getFarmAggregator,
}

