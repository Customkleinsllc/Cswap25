import { BIG_TEN } from '@CryptoSwap/utils/bigNumber'
import memoize from '@CryptoSwap/utils/memoize'
import BN from 'bignumber.js'

export const getFullDecimalMultiplier = memoize((decimals: number): BN => {
  return BIG_TEN.pow(decimals)
})
