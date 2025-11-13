import { useState, useCallback, useEffect } from 'react'
import { useAccount, useChainId } from 'wagmi'
import { getDexAggregator, Quote } from '../services/dexAggregator'
import { useSendTransaction } from 'wagmi'
import { parseEther } from 'viem'

export interface UseAggregatorQuoteParams {
  fromToken?: string
  toToken?: string
  amount?: string
  slippage?: number
  enabled?: boolean
}

export function useDexAggregatorQuote(params: UseAggregatorQuoteParams) {
  const { address } = useAccount()
  const chainId = useChainId()
  const [quote, setQuote] = useState<Quote | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)

  const { fromToken, toToken, amount, slippage = 1, enabled = true } = params

  useEffect(() => {
    if (!enabled || !fromToken || !toToken || !amount || !address || !chainId) {
      setQuote(null)
      return
    }

    const fetchQuote = async () => {
      setIsLoading(true)
      setError(null)

      try {
        const aggregator = getDexAggregator()
        const result = await aggregator.getBestQuote({
          fromToken,
          toToken,
          amount,
          chainId,
          userAddress: address,
          slippage,
        })

        setQuote(result)
      } catch (err) {
        console.error('Error fetching quote:', err)
        setError(err as Error)
        setQuote(null)
      } finally {
        setIsLoading(false)
      }
    }

    // Debounce the quote fetching
    const timeoutId = setTimeout(fetchQuote, 500)

    return () => clearTimeout(timeoutId)
  }, [fromToken, toToken, amount, chainId, address, slippage, enabled])

  return { quote, isLoading, error }
}

export function useDexAggregatorSwap() {
  const { address } = useAccount()
  const chainId = useChainId()
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)
  const { sendTransactionAsync } = useSendTransaction()

  const executeSwap = useCallback(
    async (params: {
      fromToken: string
      toToken: string
      amount: string
      slippage?: number
      onSuccess?: (txHash: string) => void
      onError?: (error: Error) => void
    }) => {
      if (!address || !chainId) {
        throw new Error('Wallet not connected')
      }

      setIsLoading(true)
      setError(null)

      try {
        // Get the quote with transaction data
        const aggregator = getDexAggregator()
        const quote = await aggregator.getBestQuote({
          fromToken: params.fromToken,
          toToken: params.toToken,
          amount: params.amount,
          chainId,
          userAddress: address,
          slippage: params.slippage || 1,
        })

        // Execute the swap transaction
        const txHash = await sendTransactionAsync({
          to: quote.tx.to as `0x${string}`,
          data: quote.tx.data as `0x${string}`,
          value: BigInt(quote.tx.value),
          gas: BigInt(quote.tx.gas),
        })

        params.onSuccess?.(txHash)
        return txHash
      } catch (err) {
        console.error('Error executing swap:', err)
        const error = err as Error
        setError(error)
        params.onError?.(error)
        throw err
      } finally {
        setIsLoading(false)
      }
    },
    [address, chainId, sendTransactionAsync]
  )

  return { executeSwap, isLoading, error }
}

export function useDexAggregatorHealth() {
  const chainId = useChainId()
  const [isHealthy, setIsHealthy] = useState<boolean | null>(null)

  useEffect(() => {
    const checkHealth = async () => {
      try {
        const aggregator = getDexAggregator()
        const healthy = await aggregator.healthCheck(chainId)
        setIsHealthy(healthy)
      } catch (err) {
        console.error('Health check error:', err)
        setIsHealthy(false)
      }
    }

    checkHealth()
    const interval = setInterval(checkHealth, 60000) // Check every minute

    return () => clearInterval(interval)
  }, [chainId])

  return isHealthy
}

