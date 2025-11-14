import { ChainId } from '@CryptoSwap/chains'
import { ERC20Token } from '@CryptoSwap/sdk'

import { USDC } from './common'

export const avalancheTokens = {
  wavax: new ERC20Token(
    ChainId.AVALANCHE,
    '0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7',
    18,
    'WAVAX',
    'Wrapped AVAX',
    'https://www.avax.network',
  ),
  usdc: USDC[ChainId.AVALANCHE],
}

