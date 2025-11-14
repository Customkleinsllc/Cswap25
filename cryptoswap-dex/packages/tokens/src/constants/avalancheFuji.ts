import { ChainId } from '@CryptoSwap/chains'
import { ERC20Token } from '@CryptoSwap/sdk'

import { USDC } from './common'

export const avalancheFujiTokens = {
  wavax: new ERC20Token(
    ChainId.AVALANCHE_FUJI,
    '0xd00ae08403B9bbb9124bB305C09058E32C39A48c',
    18,
    'WAVAX',
    'Wrapped AVAX',
    'https://www.avax.network',
  ),
  usdc: USDC[ChainId.AVALANCHE_FUJI],
}

