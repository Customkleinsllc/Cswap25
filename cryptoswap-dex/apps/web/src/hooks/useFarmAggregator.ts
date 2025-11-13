import { useState, useEffect, useCallback } from 'react'
import { useChainId } from 'wagmi'
import { getFarmAggregator, AggregatedFarm, FarmFilters } from '../services/farmAggregator'

export function useFarmList(filters?: FarmFilters) {
  const chainId = useChainId()
  const [farms, setFarms] = useState<AggregatedFarm[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchFarms = useCallback(async () => {
    setIsLoading(true)
    setError(null)

    try {
      const aggregator = getFarmAggregator()
      const result = await aggregator.getAggregatedFarms({
        ...filters,
        chainId: filters?.chainId || chainId,
      })
      setFarms(result)
    } catch (err) {
      console.error('Error fetching farms:', err)
      setError(err as Error)
      setFarms([])
    } finally {
      setIsLoading(false)
    }
  }, [chainId, filters])

  useEffect(() => {
    fetchFarms()
  }, [fetchFarms])

  const refetch = useCallback(() => {
    const aggregator = getFarmAggregator()
    aggregator.clearCache()
    fetchFarms()
  }, [fetchFarms])

  return {
    farms,
    isLoading,
    error,
    refetch,
  }
}

export function useTopFarms(limit = 20) {
  const [farms, setFarms] = useState<AggregatedFarm[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    const fetchTopFarms = async () => {
      setIsLoading(true)
      setError(null)

      try {
        const aggregator = getFarmAggregator()
        const result = await aggregator.getTopFarms(limit)
        setFarms(result)
      } catch (err) {
        console.error('Error fetching top farms:', err)
        setError(err as Error)
        setFarms([])
      } finally {
        setIsLoading(false)
      }
    }

    fetchTopFarms()
  }, [limit])

  return {
    farms,
    isLoading,
    error,
  }
}

export function useChainFarmStats() {
  const chainId = useChainId()
  const [stats, setStats] = useState<any>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    const fetchStats = async () => {
      setIsLoading(true)
      setError(null)

      try {
        const aggregator = getFarmAggregator()
        const result = await aggregator.getChainStats(chainId)
        setStats(result)
      } catch (err) {
        console.error('Error fetching chain stats:', err)
        setError(err as Error)
        setStats(null)
      } finally {
        setIsLoading(false)
      }
    }

    fetchStats()
  }, [chainId])

  return {
    stats,
    isLoading,
    error,
  }
}

export function useFarmsByProtocol(protocol: string) {
  const chainId = useChainId()
  const [farms, setFarms] = useState<AggregatedFarm[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    const fetchProtocolFarms = async () => {
      setIsLoading(true)
      setError(null)

      try {
        const aggregator = getFarmAggregator()
        const result = await aggregator.getFarmsByProtocol(protocol, chainId)
        setFarms(result)
      } catch (err) {
        console.error('Error fetching protocol farms:', err)
        setError(err as Error)
        setFarms([])
      } finally {
        setIsLoading(false)
      }
    }

    if (protocol) {
      fetchProtocolFarms()
    }
  }, [protocol, chainId])

  return {
    farms,
    isLoading,
    error,
  }
}

