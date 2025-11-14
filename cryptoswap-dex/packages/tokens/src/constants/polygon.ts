import { ChainId } from '@CryptoSwap/chains'
import { ERC20Token, WETH9 } from '@CryptoSwap/sdk'

import { USDC } from './common'

export const polygonTokens = {
  wmatic: new ERC20Token(
    ChainId.POLYGON,
    '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270',
    18,
    'WMATIC',
    'Wrapped MATIC',
    'https://polygon.technology',
  ),
  usdc: USDC[ChainId.POLYGON],
}

