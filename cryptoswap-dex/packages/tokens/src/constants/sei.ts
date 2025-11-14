import { ChainId } from '@CryptoSwap/chains'
import { ERC20Token } from '@CryptoSwap/sdk'
import { WSEI } from '@CryptoSwap/swap-sdk-evm'

import { USDC } from './common'

export const seiTokens = {
  wsei: WSEI[ChainId.SEI],
  usdc: USDC[ChainId.SEI],
}

