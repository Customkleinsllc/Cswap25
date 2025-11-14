import { ChainId } from '@CryptoSwap/chains'
import { ERC20Token } from '@CryptoSwap/sdk'
import { WAVAX } from '@CryptoSwap/swap-sdk-evm'

import { USDC } from './common'

export const avalancheTokens = {
  wavax: WAVAX[ChainId.AVALANCHE],
  usdc: USDC[ChainId.AVALANCHE],
}

