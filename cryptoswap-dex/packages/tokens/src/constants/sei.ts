import { ChainId } from '@CryptoSwap/chains'
import { ERC20Token } from '@CryptoSwap/sdk'

import { USDC } from './common'

export const seiTokens = {
  wsei: new ERC20Token(
    ChainId.SEI,
    '0xE30feDd158A2e3b13e9badaeABaFc5516e95e8C7',
    18,
    'WSEI',
    'Wrapped SEI',
    'https://www.sei.io',
  ),
  usdc: USDC[ChainId.SEI],
}

