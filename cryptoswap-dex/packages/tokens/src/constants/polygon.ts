import { ChainId } from '@CryptoSwap/chains'
import { ERC20Token } from '@CryptoSwap/sdk'
import { WMATIC } from '@CryptoSwap/swap-sdk-evm'

import { USDC } from './common'

export const polygonTokens = {
  wmatic: WMATIC[ChainId.POLYGON],
  usdc: USDC[ChainId.POLYGON],
}

