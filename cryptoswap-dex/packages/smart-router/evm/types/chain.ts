import { Token } from '@CryptoSwap/sdk'
import { ChainId } from '@CryptoSwap/chains'

// a list of tokens by chain
export type ChainMap<T> = {
  readonly [chainId in ChainId]: T
}

export type ChainTokenList = ChainMap<Token[]>
