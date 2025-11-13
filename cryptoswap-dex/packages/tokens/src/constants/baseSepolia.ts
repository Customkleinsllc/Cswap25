import { ChainId } from '@CryptoSwap/chains'
import { WETH9 } from '@CryptoSwap/sdk'
import { USDC } from './common'

export const baseSepoliaTokens = {
  weth: WETH9[ChainId.BASE_SEPOLIA],
  usdc: USDC[ChainId.BASE_SEPOLIA],
}
