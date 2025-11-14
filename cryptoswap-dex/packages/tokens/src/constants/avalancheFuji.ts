import { ChainId } from '@CryptoSwap/chains'
import { ERC20Token } from '@CryptoSwap/sdk'
import { WAVAX } from '@CryptoSwap/swap-sdk-evm'

import { USDC } from './common'

export const avalancheFujiTokens = {
  wavax: WAVAX[ChainId.AVALANCHE_FUJI],
  usdc: USDC[ChainId.AVALANCHE_FUJI],
}

