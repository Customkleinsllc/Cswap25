import type { Pool } from '@CryptoSwap/routing-sdk'
import {
  InfinityBinPool,
  InfinityCLPool,
  isInfinityBinPool,
  isInfinityCLPool,
} from '@CryptoSwap/routing-sdk-addon-infinity'

type Route<P extends Pool = Pool> = {
  pools: P[]
}

export function isInfinityCLRoute(r: Route<Pool>): r is Route<InfinityCLPool> {
  const { pools } = r
  return pools.every((p) => isInfinityCLPool(p))
}

export function isInfinityBinRoute(r: Route<Pool>): r is Route<InfinityBinPool> {
  const { pools } = r
  return pools.every((p) => isInfinityBinPool(p))
}
