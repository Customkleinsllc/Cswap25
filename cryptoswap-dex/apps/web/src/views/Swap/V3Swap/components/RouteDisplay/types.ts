import { Route } from '@CryptoSwap/smart-router'
import { Currency } from '@CryptoSwap/swap-sdk-core'

export type RouteDisplayEssentials = Pick<Route, 'path' | 'pools' | 'inputAmount' | 'outputAmount' | 'percent' | 'type'>

export type Pair = [Currency, Currency]
