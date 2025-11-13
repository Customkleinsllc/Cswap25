import { defaultChain } from '@pancakeswap/awgmi'
import { mainnet, testnet, Chain } from '@pancakeswap/awgmi/core'

export { defaultChain }

export const chains = [mainnet, testnet].filter(Boolean) as Chain[]

export const SOLANA_MENU = {
  id: 2,
  name: 'Solana',
  link: process.env.SOLANA_SWAP_PAGE ?? 'https://solana.cryptoswap.com/swap',
  image: 'https://tokens.cryptoswap.com/images/symbol/sol.png',
}

