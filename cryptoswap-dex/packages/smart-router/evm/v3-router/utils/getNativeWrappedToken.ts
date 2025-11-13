import { Token, WNATIVE } from '@CryptoSwap/sdk'
import { ChainId } from '@CryptoSwap/chains'

export function getNativeWrappedToken(chainId: ChainId): Token | null {
  return WNATIVE[chainId] ?? null
}
