import { ChainId, Currency } from '@CryptoSwap/sdk'
import { CAKE } from '@CryptoSwap/tokens'
import { ADDRESS_ZERO } from 'config/constants'
import { useTokensByChainWithNativeToken } from 'hooks/useTokensByChainWithNativeToken'
import { useMemo } from 'react'
import { Address } from 'viem'

export const useFindTokens = (chainId: ChainId, tokenAddress: Address) => {
  const tokensByChainWithNativeToken = useTokensByChainWithNativeToken((chainId as ChainId) ?? ChainId.BSC)

  const token = useMemo((): Currency => {
    const findToken = tokensByChainWithNativeToken.find((i) =>
      i.isNative
        ? ADDRESS_ZERO?.toLowerCase() === tokenAddress?.toLowerCase()
        : i.address.toLowerCase() === tokenAddress?.toLowerCase(),
    )
    return findToken || (CAKE as any)?.[chainId]
  }, [chainId, tokenAddress, tokensByChainWithNativeToken])

  return token
}
