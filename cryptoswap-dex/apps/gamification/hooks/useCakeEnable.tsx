import { ChainId } from '@CryptoSwap/chains'
import { Native } from '@CryptoSwap/sdk'
import { CAKE } from '@CryptoSwap/tokens'
import { getFullDisplayBalance } from '@CryptoSwap/utils/formatBalance'
import tryParseAmount from '@CryptoSwap/utils/tryParseAmount'
import BigNumber from 'bignumber.js'
import { INITIAL_ALLOWED_SLIPPAGE } from 'config/constants'
import { useTradeExactOut } from 'hooks/Trades'
import useActiveWeb3React from 'hooks/useActiveWeb3React'
import { useSwapCallArguments } from 'hooks/useSwapCallArguments'
import { useSwapCallback } from 'hooks/useSwapCallback'
import { useCallback, useEffect, useMemo, useState } from 'react'
import { useAppDispatch } from 'state'
import { useIsTransactionPending } from 'state/transactions/hooks'

export const useCakeEnable = (enableAmount: BigNumber) => {
  const { account, chainId } = useActiveWeb3React()
  const dispatch = useAppDispatch()
  const [pendingEnableTx, setPendingEnableTx] = useState(false)
  const [transactionHash, setTransactionHash] = useState<string>()
  const isTransactionPending = useIsTransactionPending(transactionHash)
  const swapAmount = useMemo(() => getFullDisplayBalance(enableAmount), [enableAmount])

  const parsedAmount = tryParseAmount(swapAmount, chainId ? (CAKE as any)[chainId] : undefined)

  const trade = useTradeExactOut(Native.onChain(ChainId.BSC), parsedAmount)

  const swapCalls = useSwapCallArguments(trade, INITIAL_ALLOWED_SLIPPAGE, null)

  const { callback: swapCallback } = useSwapCallback(trade, INITIAL_ALLOWED_SLIPPAGE, null, swapCalls)

  useEffect(() => {
    if (pendingEnableTx && transactionHash && !isTransactionPending && account && chainId) {
      setPendingEnableTx(isTransactionPending)
    }
  }, [account, dispatch, transactionHash, pendingEnableTx, isTransactionPending, chainId])

  const handleEnable = useCallback(() => {
    if (!swapCallback) {
      return
    }
    setPendingEnableTx(true)
    swapCallback()
      .then((hash) => {
        setTransactionHash(hash)
      })
      .catch(() => {
        setPendingEnableTx(false)
      })
  }, [swapCallback])

  return { handleEnable, pendingEnableTx }
}
