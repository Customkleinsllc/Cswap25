import { WETH9 } from '@CryptoSwap/sdk'
import { ChainId } from '@CryptoSwap/chains'
import { USDC } from './common'

export const scrollSepoliaTokens = {
  weth: WETH9[ChainId.SCROLL_SEPOLIA],
  usdc: USDC[ChainId.SCROLL_SEPOLIA],
}
